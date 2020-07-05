class Project < ApplicationRecord
  include ProjectConstants
  include Syncable
  include Rails.application.routes.url_helpers

  attr_accessor :tech_stack_names, :non_tech_stack_names, :needs_category_names, :skip_new_project_notification_email, :skip_new_project_slack_notification, :skip_push_to_airtable

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

  before_save :push_changes_to_airtable, unless: :skip_push_to_airtable

  after_create :send_new_project_slack_notification, unless: :skip_new_project_slack_notification

  after_create :send_new_project_notification_emails, unless: :skip_new_project_notification_email

  before_save :remove_blank_values

  scope :simple_search,   -> (q) do
    q = "%#{q}%"
    where("name ILIKE ? OR description ILIKE ?", q, q).order("created_at ASC")
  end

  audited
  has_associated_audits

  def self.projects_slack_channel
    "CLUDUR2MD"
  end

  def self.matching_airtable_attributes
    {
      "Project Name" => :name,
      "Project Summary TEXT" => :description,
      "Website" => :website,
      "Active Contributors (full time equivalent)" => :active_contributors,
      "Full release features" => :full_release_features,
      "Mission accomplished" => :mission_accomplished,
      "Needs / Pain Points - Narrative" => :needs_pain_points_narrative,
      "Org Structure" => :org_structure,
      "Project Mgmt URL" => :project_mgmt_url,
      "Repository" => :repository,
      "Software License URL" => :software_license_url,
      "Values Screening" => :values_screening,
      "Working doc" => :working_doc,
      "Attachments" => :attachments,
      "ProgCode Github Project Link" => :progcode_github_project_link,
      "Project Status" => :status,
      "Business model" => :business_models,
      "Legal structure" => :legal_structures,
      "OSS License Type" => :oss_license_types,
      "Project Applications" => :project_applications,
      "Needs Categories" => :needs_category_names,
      "Tech Stack" => :tech_stack_names,
      "Non-Tech Stack" => :non_tech_stack_names
    }
  end

  def self.matching_airtable_boolean_attributes
    {
      "Mission Aligned" => :mission_aligned
    }
  end

  def slack_channel_for_url
    if self.slack_channel_id.present?
      self.slack_channel_id
    elsif self.slack_channel.present?
      self.slack_channel
    else
      nil
    end
  end

  def leads
    lead_ids.blank? ? [] : User.where(:id => self.lead_ids)
  end

  def progcode_coordinators
    progcode_coordinator_ids.blank? ? [] : User.where(:id => self.progcode_coordinator_ids)
  end

  def all_contributors
    leads + active_volunteers + progcode_coordinators
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
    self.status  = self.status.try(:reject, &:empty?)
    self.legal_structures = self.legal_structures.try(:reject, &:empty?)
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

  def self.mission_aligned_designated(designation = 'pending')
    self.all.select{ |project| project.mission_aligned_status == designation.downcase }
  end

  ransacker :by_mission_aligned_status, { formatter: proc { |string| 
    data = self.mission_aligned_designated(string).map(&:id)
    data = data.present? ? data : nil
  }, callable: proc { |parent|
    parent.table[:id]}}

  
  def self.status_designated(string)
    self.all.select{ |project| project.status.include?(string) }
  end

  ransacker :by_status, { formatter: proc { |string|
    data = self.status_designated(string).map(&:id)
    data = data.present? ? data : nil }, callable: proc { |parent|
    parent.table[:id]}}

  def self.users_found(string, role)
    self.all.select{ |project| project.send(role).pluck(:name, :slack_username, :email).join.include?(string) }
  end
  
  ransacker :by_leads, { formatter: proc { |string|
    data = self.users_found(string, 'leads').map(&:id)
    data = data.present? ? data : nil }, callable:
    proc { |parent|
    parent.table[:id]}}

  ransacker :by_volunteers, { formatter: proc { |string|
    data = self.users_found(string, 'volunteers').map(&:id)
    data = data.present? ? data : nil }, callable:
    proc { |parent|
    parent.table[:id]}}

  ransacker :by_progcode_coordinators, { formatter: proc { |string|
    data = self.users_found(string, 'progcode_coordinators').map(&:id)
    data = data.present? ? data : nil }, callable:
    proc { |parent|
    parent.table[:id]}}

  def designate_flagged
    case self.flagged?
    when true
      'Yes'
    when false
      'No'
    end
  end
  
  def self.flagged_designated(designation = 'No')
    self.all.select{|project| project.designate_flagged == designation }
  end

  ransacker :by_flagged, { formatter: proc { |string|
  data = self.flagged_designated(string).map(&:id)
  data = data.present? ? data : nil }, callable:
  proc { |parent|
  parent.table[:id]}}

  def get_slack_channel_id(channel_name)


    channel = SlackHelpers.get_slack_channels.find {|channel| channel["name"] == channel_name}

      unless channel.blank?

        self.slack_channel_id = channel.id
      end
  rescue Slack::Web::Api::Errors::SlackError => e
    puts "SlackBot:  Channel does not exist"
    return nil
  end

  def get_slack_channel_name(channel_id)
    channel_info = SlackHelpers.get_channel_info(channel_id)

    unless channel_info.blank?
      self.slack_channel = channel_info.channel.name
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
    }, testing = cast_string_to_boolean(ENV['NOTIFICATION_TESTING']))
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
      }, testing = cast_string_to_boolean(ENV['NOTIFICATION_TESTING']))
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
      }, testing = cast_string_to_boolean(ENV['NOTIFICATION_TESTING']))
    end
  end

  def push_changes_to_airtable
    
    self.remove_blank_values
    
    super do |airtable_project|
      all_slack_channels = AirtableChannelList.all

      airtable_project.project_leads = self.leads.map {|l| l.airtable_twin}.compact

      airtable_project.members = self.active_volunteers.map {|v| v.airtable_twin }.compact

      airtable_project.progcode_coordinators = self.progcode_coordinators.map { |c| c.airtable_twin.try(:airtable_base_manager) }.compact

      master_channels = self.master_channel_list.map {|m| all_slack_channels.detect{|x| x["Channel Name"] == m}}

      airtable_master_channel_ids = master_channels.compact.map{|x| x.id}

      if airtable_master_channel_ids.present?
        airtable_project.master_channel_lists = AirtableChannelList.find_many(airtable_master_channel_ids)
      end

      if self.slack_channel_id.present?
        airtable_channel = all_slack_channels.detect{|x| x["Channel ID"] == self.slack_channel_id}
      elsif self.slack_channel.present?
        airtable_channel = all_slack_channels.detect{|x| x["Channel Name"] == self.slack_channel}
      end

      if airtable_channel.present?
        airtable_project.slack_channel = 
      AirtableChannelList.find(airtable_channel.id)
      end
    end
  end

  def sync_with_airtable(airtable_project)
    self.skip_push_to_airtable = true

    if self.new_record?
      self.skip_new_project_notification_email = true
      self.skip_new_project_slack_notification = true
    end

    if airtable_project["Project Name"].blank?
      self.flags << "this project lacks a name"
    end
    
    if airtable_project["Project Status"].blank?
      self.flags << "this project lacks a status"
    end

    if !airtable_project.project_leads.present?
      self.flags << "this project lacks a lead"
      lead_ids = []
    else
      lead_ids = airtable_project.project_leads.map do |project_lead|
        airtable_id = project_lead["Record ID"]
        lead = User.find_by(:airtable_id => airtable_id)
        if lead == nil
          self.flags << "project lead slack id #{slack_id} has no corresponding user"
          nil
        else
          lead.id
        end
      end
    end
    self.lead_ids = lead_ids.compact

    if airtable_project.members.present?
      airtable_ids = airtable_project.members.pluck("Record ID")
      volunteer_airtable_ids = airtable_ids.reject {|x| airtable_project.project_leads.pluck("Record ID").include?(x)}
      volunteers = User.where(:airtable_id => volunteer_airtable_ids)
      new_volunteers = volunteers.reject{|v| self.active_volunteer_ids.include?(v.id)}
      volunteerings = new_volunteers.map{|v| self.volunteerings.build(user_id: v.id)}
      volunteerings.each do |v|
        v.skip_sending_volunteering_updates = true
        v.set_active!(ENV['AASM_OVERRIDE'])
        v.skip_sending_volunteering_updates = false
      end
      former_member_airtable_ids = self.active_volunteers.pluck(:airtable_id) - Array(airtable_project.members.try(:pluck, "Record ID"))


      if volunteer_airtable_ids.size > volunteers.size
        missing = volunteer_airtable_ids - volunteers.map(&:slack_userid).compact
        self.flags += missing.map { |m| "volunteer slack id #{m} has no corresponding user" }
      end

      if former_member_airtable_ids.present?
        former_member_ids = User.where(:airtable_id => former_member_airtable_ids).pluck(:id)
        former_volunteerings = self.active_volunteerings.where(:user_id => former_member_ids)
        former_volunteerings.each do |fv|
          fv.skip_sending_volunteering_updates = true
          fv.set_former!(ENV['AASM_OVERRIDE'])
          v.skip_sending_volunteering_updates = false
        end
      end

    end

    if !airtable_project.progcode_coordinators.present?
      self.flags << "this project lacks a coordinator"
      progcode_coordinator_ids = []
    else
      progcode_coordinator_ids = 
      airtable_project.progcode_coordinators.map do |coord|
        coordinator = User.where(slack_username: coord["Slack Handle"].gsub("@", "")).first
        unless coordinator.present?
          self.flags << "progcode coordinator slack handle #{coord["Slack Handle"]} has no corresponding user"
          nil
        else
          coordinator.id
        end
      end
    end
    self.progcode_coordinator_ids = progcode_coordinator_ids.compact

    if airtable_project["Needs Categories"].blank?
      self.needs_category_ids = []
    else
      self.need_category_ids = Skill.match_with_airtable(airtable_skills: airtable_project["Needs Categories"], tech: false)
    end
    
    if airtable_project["Tech Stack"].blank?
      self.flags << "this project lacks a tech stack"
      self.tech_stack_ids = []
    else
      self.tech_stack_ids = Skill.match_with_airtable(airtable_skills: airtable_project["Tech Stack"], tech: true)
    end

    if airtable_project["Non-Tech Stack"].blank?
      self.non_tech_stack_ids = []
    else
      self.non_tech_stack_ids = Skill.match_with_airtable(airtable_skills: airtable_project["Non-Tech Stack"], tech: false)
    end

    if airtable_project.slack_channel.present?
      if airtable_project.slack_channel["Channel ID"].present?
        self.slack_channel_id = airtable_project.slack_channel["Channel ID"]

        self.get_slack_channel_name(self.slack_channel_id)
      elsif airtable_project.slack_channel["Channel Name"].present?
        self.slack_channel = airtable_project.slack_channel["Channel Name"]

        self.get_slack_channel_id(self.slack_channel)
      end
    end

    master_channel_names = airtable_project.master_channel_lists.map { |channel|
      channel["Channel Name"] }
    
    self.master_channel_list = master_channel_names.compact
    
    self.assign_attributes(self.build_attributes(airtable_project))

    if self.legal_structures.blank?
      self.flags << "this project lacks a legal structure"
    end

    if self.progcode_github_project_link == nil
      self.flags << "this project lacks a link to a github repository"
    end

    self.mission_aligned = true
    self.flags.uniq!
    self.save(:validate => false)
    self.skip_push_to_airtable = false
  end

  def build_attributes(airtable_project)
    {
      name: airtable_project["Project Name"],
      status: airtable_project["Project Status"],
      description: airtable_project["Project Summary TEXT"], 
      needs_pain_points_narrative: airtable_project["Needs / Pain Points - Narrative"],
      legal_structures: airtable_project["Legal structure"],
      active_contributors: airtable_project["Active Contributors (full time equivalent)"],
      business_models: airtable_project["Business model"],
      oss_license_types: airtable_project["OSS License Type"]
    }.merge(self.extract_fields(airtable_project))
  end
  
  def extract_assoc(key, field)
    return [] if self[key].blank?
    self[key].map {|obj| obj[field] }
  end
  
  def extract_fields(airtable_project)
    hsh = {}.tap do |h|
      extracted_fields = airtable_project.fields.keys - ["Project Name", "Project Summary Text",
        "Progcode Coordinator IDs", "Tech Stack", "Project Status", "Team Member IDs",
        "Project Lead Slack ID", "Slack Channel", "Needs Categories", "Master Channel List", "Needs / Pain Points - Narrative", "Legal structure", "Active Contributors (full time equivalent)", "Business model", "OSS License Type"]
      extracted_fields.each do |key|
        downcased_key = key.downcase.gsub(" ", "_")
        next if Project.column_for_attribute(downcased_key).table_name.blank?
        if airtable_project[key].is_a?(Array) && (!Project.column_for_attribute(downcased_key).array)
          h[downcased_key] = airtable_project[key].first
        else
          h[downcased_key] = airtable_project[key]
        end
      end
    end
  end


end