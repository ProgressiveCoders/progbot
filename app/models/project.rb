class Project < ApplicationRecord
  include ProjectConstants
  include SlackHelpers
  include Rails.application.routes.url_helpers

  attr_accessor :tech_stack_names, :non_tech_stack_names, :needs_category_names

  has_and_belongs_to_many :needs_categories, class_name: "Skill", join_table: "needs_categories"
  
  has_and_belongs_to_many :stacks, class_name: "Skill", join_table: "projects_skills"
  
  has_and_belongs_to_many :tech_stack, -> { where tech: true }, class_name: "Skill", join_table: "projects_skills"
  has_and_belongs_to_many :non_tech_stack, -> { where tech: !true }, class_name: "Skill", join_table: "projects_skills"

  has_many :volunteerings, dependent: :destroy
  has_many :volunteers, through: :volunteerings, source: 'user'
  has_many :active_volunteerings,  -> { where state: 'active' }, class_name: 'Volunteering'
  has_many :active_volunteers, through: :active_volunteerings, source: 'user'

  validates_presence_of :name, :description, :tech_stack, :tech_stack_names
  
  validates :legal_structures, :presence => true, :allow_blank => false, :if => :new_record?

  after_create :send_new_project_slack_notification
  
  after_create :send_new_project_notification_emails

  after_save :remove_blank_values
  audited
  has_associated_audits
  
  def self.projects_slack_channel
    "CLUDUR2MD"
  end
  
  def leads
    lead_ids.blank? ? [] : User.where(:id => self.lead_ids)
  end

  def progcode_coordinators
    progcode_coordinator_ids.blank? ? [] : User.where(:id => self.progcode_coordinator_ids)
  end
  
  def leads=(users)
    self.lead_ids = users.map(&:id)
  end

  def tech_tack_names=(stack_names)
    self.tech_stack_ids = Skill.where(name: stack_names.split(", ")).pluck(:id)
  end

  def tech_stack_names
    if self.tech_stack.blank?
      []
    else
      self.tech_stack.map { |stack| stack.name }
    end
  end
  

  def non_tech_stack_names=(stack_names)
    self.non_tech_stack_ids = Skill.where(name: stack_names.split(", ")).pluck(:id)
  end

  def non_tech_stack_names
    if self.tech_stack.blank?
      []
    else
      self.non_tech_stack.map { |stack| stack.name }
    end
  end

  def needs_category_names=(category_names)
    self.needs_category_ids = Skill.where(name: category_names.split(", ")).pluck(:id)
  end

  def needs_category_names
    if self.needs_categories.blank?
      []
    else
      self.needs_categories.map { |need| need.name }
    end
  end

  def flagged?
    !self.flags.blank?
  end

  def remove_blank_values
    self.status  = self.status.reject(&:empty?)
    self.legal_structures = self.legal_structures.reject(&:empty?)
  end

  def mission_aligned_status(mission_aligned = self.mission_aligned)
    if mission_aligned == true
      'confirmed'
    elsif mission_aligned == false
      'rejected'
    elsif mission_aligned.nil?
      'pending'
    end

  end

  def get_slack_channel_id(channel_name)


    channel = SlackHelpers.get_slack_channels.find {|channel| channel["name"] == channel_name}

      unless channel.blank?

        self.slack_channel_id = channel.id
      end
  rescue Slack::Web::Api::Errors::SlackError => e
    puts "SlackBot:  Channel does not exist"
    return nil
  end

  def get_ids_from_names(tech_names, non_tech_names, needs_category_names)
    self.tech_stack = Skill.where(:name => tech_names)
    self.non_tech_stack = Skill.where(:name => non_tech_names)
    self.needs_categories = Skill.where(:name => needs_category_names)
  end

  def send_new_project_notification_emails
    user = User.find(self.lead_ids.first)
    EmailNotifierMailer.with(user: user, project: self).new_project_confirmation.deliver_later
    EmailNotifierMailer.with({user: user, project: self}).new_project_admin_notification.deliver_later
  end

  def send_mission_aligned_changed_notification_email(mission_aligned_was)
    EmailNotifierMailer.with({project: self, mission_aligned_was: mission_aligned_was}).project_mission_aligned_changed.deliver_later
  end

  def send_new_project_slack_notification
    SlackBot.send_message({
      channel: Project.projects_slack_channel,
      attachments: [
        pretext: "New Project Created",
        title: "A New Project Has Been Created: #{self.name}",
        title_link: admin_project_url(self),
        text: "This project is pending admin approval."
      ]
    }, testing = false)
  end

  def send_mission_aligned_changed_slack_notifications(mission_aligned_was)
    self.leads.each do |lead|
      SlackBot.send_message({
        channel: lead.slack_userid,
        attachments: [
          pretext: "Mission Aligned Status Changed",
          title: "Your Project's Mission Aligned Status has Changed",
          text: "The mission aligned status of your project, #{self.name} has changed from #{mission_aligned_was} to #{self.mission_aligned_status}.",
          title_link: dashboard_projects_url
        ]
      }, testing = true)
    end

    if self.mission_aligned
      SlackBot.send_message({
        channel: Project.projects_slack_channel,
        attachments: [
          pretext: "Project Has been Approved",
          title: "#{self.name} has been validated as mission aligned.",
          text: "Click the link above to view this project and to volunteer",
          title_link: dashboard_project_url(self)
        ]
      }, testing = false)
    end
  end


end
