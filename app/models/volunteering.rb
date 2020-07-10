class Volunteering < ApplicationRecord
  include AASM
  include Rails.application.routes.url_helpers
  include Syncable

  belongs_to :user
  belongs_to :project

  validates :project, presence: true
  validates :user, presence: true

  validates_uniqueness_of :user_id, :scope => :project_id, :message => "User can only volunteer once per project"

  audited associated_with: :project
  audited associated_with: :user

  attr_accessor :event, :skip_sending_volunteering_updates

  aasm :column => 'state' do
    state :potential, initial: true
    state :signed_up
    state :invited
    state :active
    state :former
    
    event :set_active, after: :send_volunteering_updates do
      transitions from: [:potential, :signed_up, :invited, :resigned, :removed, :former], to: :active, guard: :application_override?
    end

    event :set_former, after: :send_volunteering_updates do
      transitions from: [:potential, :signed_up, :invited, :active, :resigned, :removed], to: :former, guard: :application_override?
    end
    
    event :apply do
      after do
        send_volunteering_email
        send_volunteering_updates
      end
      transitions from: [:potential, :former], to: :signed_up, guard: :user_is_not_lead?
    end
    
    event :recruit, after: :send_recruitment_messages do
      transitions from: [:potential, :former], to: :invited, guard: :user_is_lead?
    end

    event :withdraw, after: :send_volunteering_updates do
      transitions from: [:signed_up, :invited], to: :potential, guard: :user_can_withdraw?
    end

    event :confirm, after: :send_volunteering_updates, guard: :user_can_confirm? do
        transitions from: [:signed_up, :invited], to: :active
    end

    event :leave, after: :send_volunteering_updates do
      transitions from: :active, to: :former, guard: :user_is_volunteer?
    end

    event :remove, after: :send_volunteering_updates do
      transitions from: :active, to: :former, guard: :user_is_lead?
    end

  end

  def application_override?(key)
    key == ENV['AASM_OVERRIDE']
  end

  def user_is_not_lead?(user)
    !self.project.leads.include?(user) and user.is_a? User
  end

  def user_is_lead?(user)
    self.project.leads.include?(user)
  end

  def user_is_volunteer?(user)
    user == self.user
  end

  def user_can_withdraw?(user)
    if self.signed_up?
      user_is_volunteer?(user)
    elsif self.invited?
      user_is_lead?(user)
    end
  end

  def user_can_confirm?(user)
    if self.signed_up?
      user_is_lead?(user)
    elsif self.invited?
      user_is_volunteer?(user)
    end
  end

  def self.get_volunteering_id(project, user)
    volunteering = Volunteering.find_by(:project_id => project.id, :user_id => user.id)

    volunteering.id
  end

  def relevant?
    ['signed_up', 'invited', 'active'].include?(self.state)
  end

  def send_volunteering_email
    project = self.project
    user = self.user

    if project.leads.any? && project.leads.pluck(:email).any?
      if self.state == "signed_up"
        EmailNotifierMailer.with(user: user, project: project, volunteering: self, emails: project.leads.pluck(:email)).new_volunteer_email.deliver_later
      end
    else 
      if !project.flags.include?('this project lacks a lead')
        project.flags << 'this project lacks a lead'
        project.save
      end
    end
  end

  def send_volunteering_updates
    unless self.skip_sending_volunteering_updates
      leads = self.project.leads
      project = self.project
      volunteer = self.user
      coordinators = self.project.progcode_coordinators

      if volunteer.slack_userid
        send_slack_volunteering_notification(user: volunteer, title_link: edit_dashboard_volunteering_url(self), testing: cast_string_to_boolean(ENV['NOTIFICATION_TESTING']))
      end

      if !leads.empty?
        leads.each do |lead|
          send_slack_volunteering_notification(user: lead, title_link: edit_dashboard_volunteering_url(self))
        end
      else
        if !project.flags.include?('this project lacks a lead')
          project.flags << 'this project lacks a lead'
          project.save
        end

        if !coordinators.empty?
          coordinators.each do |coordinator|
            send_slack_volunteering_notification(user: coordinator, title_link: admin_volunteering_url(self))
          end
        else
          if !project.flags.include?('this project lacks a coordinator')
            project.flags << 'this project lacks a coordinator'
            project.save
          end
        end
      end
    end  
  end

  def send_recruitment_messages
    unless self.skip_sending_volunteering_updates
      leads = self.project.leads
      project = self.project
      volunteer = self.user

      attachments = [
        pretext: "Volunteering Recruitment",
        title: "Invitation to join #{self.project.name}"
      ]

      volunteer_attachments = [attachments[0].merge(
        text: "A project lead for #{self.project.name} has seen your skills in Progbot's anonymized directory and invites you to join the project! Click the link to view more details in ProgBot")]

      lead_attachments = [attachments[0].merge(
        text: "An anonymous user from ProgBot has been sent the following slack message: A project lead for #{self.project.name} has seen your skills in Progbot's anonymized directory and invites you to join the project! Click the link to view more details in ProgBot")]

      if volunteer.slack_userid
        send_slack_volunteering_notification(user: volunteer, title_link: edit_dashboard_volunteering_url(self.id), attachments: volunteer_attachments)
      end

      if volunteer.email
        EmailNotifierMailer.with(user: volunteer, project: project, volunteering: self).new_recruit_email.deliver_later
      end

      if leads.present?
        leads.each do |l|
          if l.slack_userid
            send_slack_volunteering_notification(user: l, title_link: edit_dashboard_volunteering_url(self.id), attachments: lead_attachments)
          end
          if l.email
            EmailNotifierMailer.with(user: l, project: project, volunteering: self).new_recruit_email.deliver_later
          end
        end
      end
    end
  end

  def default_slack_attachment
    [
      pretext: "Volunteering Updated",
      title: "#{self.user.slack_username}'s volunteering for #{self.project.name} has been updated",
      text: "#{self.user.slack_username}'s status has been changed from #{self.aasm.from_state} to #{self.aasm.to_state}. Click the link to view more details in ProgBot."
    ]
  end

  def send_slack_volunteering_notification(user:,title_link:,testing: cast_string_to_boolean(ENV['NOTIFICATION_TESTING']), attachments: self.default_slack_attachment)
    base_params = {
      channel: user.slack_userid,
      attachments: attachments
    }

    SlackBot.send_message(SlackBot.merge_params(base_params, {
      attachments: [
        title_link: title_link
      ]
    }), testing = testing)
  end

  def nested_label
    if self.user.slack_username
      "#{self.user.slack_username} (#{self.state})"
    elsif self.user.name
      "#{self.user.name} (#{self.state})"
    elsif self.user.slack_userid
      "#{self.user.slack_userid} (#{self.state})"
    end
  end


end