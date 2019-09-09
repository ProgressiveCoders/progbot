class Volunteering < ApplicationRecord
  include AASM
  include Rails.application.routes.url_helpers

  belongs_to :user
  belongs_to :project

  validates :project, presence: true
  validates :user, presence: true

  validates_uniqueness_of :user_id, :scope => :project_id, :message => "User can only volunteer once per project"

  audited associated_with: :project
  audited associated_with: :user

  attr_accessor :event

  aasm :column => 'state' do
    state :potential, initial: true
    state :signed_up
    state :invited
    state :active
    state :former

    after_all_transitions :send_volunteering_updates
    
    event :set_active do
      transitions from: [:potential, :signed_up, :invited, :resigned, :removed, :former], to: :active, guard: :application_override?
    end

    event :set_former do
      transitions from: [:active, :signed_up, :invited, :active, :resigned, :removed], to: :former, guard: :application_override?
    end
    
    event :apply do
        transitions from: [:potential, :former], to: :signed_up, guard: :user_is_not_lead?
    end
    
    event :recruit do
        transitions from: [:potential, :former], to: :invited, guard: :user_is_lead?
    end

    event :withdraw do
      transitions from: [:signed_up, :invited], to: :potential, guard: :user_can_withdraw?
    end

    event :confirm, guard: :user_can_confirm? do
        transitions from: [:signed_up, :invited], to: :active
    end

    event :leave do
      transitions from: :active, to: :former, guard: :user_is_volunteer?
    end

    event :remove do
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

  def send_volunteering_updates
    leads = self.project.leads
    project = self.project
    volunteer = self.user
    coordinators = self.project.progcode_coordinators

    if volunteer.slack_userid
      send_slack_volunteering_notification(user: volunteer, title_link: edit_dashboard_volunteering_url(self), testing: false)
    end

    if !leads.empty?
      leads.each do |lead|
        send_slack_volunteering_notification(user: lead, title_link: edit_dashboard_project_url(project))
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

  def send_slack_volunteering_notification(user:,title_link:,testing: true)
    base_params = {
      channel: user.slack_userid,
      attachments: [
        pretext: "Volunteering Updated",
        title: "#{self.user.slack_username}'s volunteering for #{self.project.name} has been updated",
        text: "#{self.user.slack_username}'s status has been changed from #{self.aasm.from_state} to #{self.aasm.to_state}. Click the link to view more details in ProgBot."
      ]
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