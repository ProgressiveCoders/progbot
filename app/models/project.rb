class Project < ApplicationRecord
  include ProjectConstants
  include SlackHelpers
  include Rails.application.routes.url_helpers

  attr_accessor :tech_stack_names, :non_tech_stack_names, :needs_category_names, :skip_new_project_notification_email

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

  before_save :push_changes_to_airtable

  after_create :send_new_project_slack_notification

  after_create :send_new_project_notification_emails, unless: :skip_new_project_notification_email

  after_save :remove_blank_values

  scope :simple_search,   -> (q) do
    q = "%#{q}%"
    where("name ILIKE ? OR description ILIKE ?", q, q).order("created_at ASC")
  end

  audited
  has_associated_audits

  def self.projects_slack_channel
    "CLUDUR2MD"
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

  def push_changes_to_airtable
    all_airtable_projects = AirtableProject.all
    all_slack_channels = AirtableChannelList.all

    airtable_project = self.airtable_id.present? && all_airtable_projects.detect{|x| x.id == self.airtable_id}.present? ? all_airtable_projects.detect{|x| x.id == self.airtable_id} : AirtableProject.new

    airtable_project["Project Name"] = self.name

    airtable_project["Project Summary TEXT"] = self.description

    airtable_project["Website"] = self.website

    airtable_project["Active Contributors (full time equivalent)"] = self.active_contributors

    airtable_project["Full release features"] = self.full_release_features

    airtable_project["Mission accomplished"] = self.mission_accomplished

    airtable_project["Needs / Pain Points - Narrative"] = self.needs_pain_points_narrative

    airtable_project["Org Structure"] = self.org_structure

    airtable_project["Project Mgmt URL"] = self.project_mgmt_url

    airtable_project["Repository"] = self.repository

    airtable_project["Software License URL"] = self.software_license_url

    airtable_project["Values Screening"] = self.values_screening

    airtable_project["Working doc"] = self.working_doc

    airtable_project["Attachments"] = self.attachments

    airtable_project["ProgCode Github Project Link"] = self.progcode_github_project_link

    if self.mission_aligned
      airtable_project["Mission Aligned"] = true
    end
    
    airtable_project["Project Status"] = self.status

    airtable_project["Business model"]  = self.business_models

    airtable_project["Legal structure"]  = self.legal_structures

    airtable_project["OSS License Type"] = self.oss_license_types

    airtable_project["Project Applications"] = self.project_applications

    airtable_project.project_leads = self.leads.map {|l| l.airtable_twin}.compact

    airtable_project.members = self.active_volunteers.map {|v| v.airtable_twin }.compact

    airtable_project.progcode_coordinators = self.progcode_coordinators.map { |c| c.airtable_twin.try(:airtable_base_manager) }.compact

    airtable_project["Needs Categories"] = self.needs_category_names

    airtable_project["Tech Stack"] = self.tech_stack_names

    airtable_project["Non-Tech Stack"] = self.non_tech_stack_names

    airtable_master_channel_ids = self.master_channel_list.map {|m| all_slack_channels.detect{|x| x["Channel Name"] == m}.id }
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

    airtable_project.save(typecast: true)
    self.airtable_id = airtable_project.id

  end

  def sync_with_airtable(airtable_project)
    if self.new_record?
      self.skip_new_project_notification_email = true
    end

    if airtable_project["Project Name"].blank?
      self.flags << "this project lacks a name"
    else
      self.name = airtable_project["Project Name"]
    end
    
    if airtable_project["Project Status"].blank?
      self.flags << "this project lacks a status"
    else
      airtable_project["Project Status"].each do |status|
        self.status << status
      end
    end
    self.status = self.status.uniq

    if !airtable_project.project_leads.present?
      self.flags << "this project lacks a lead"
    else
      airtable_project.project_leads.each do |project_lead|
        slack_id = project_lead["slack_id"]
        lead = User.find_by(:slack_userid => slack_id)
        if lead == nil
          self.flags << "project lead slack id #{slack_id} has no corresponding user"
        else
          self.lead_ids << lead.id
        end
      end
    end
    self.lead_ids = self.lead_ids.uniq

    if airtable_project.members.present?
      slack_ids = airtable_project.members.pluck("slack_id")
      volunteer_slack_ids = slack_ids.reject {|x| airtable_project.project_leads.pluck("slack_id").include?(x)}
      volunteers = User.where(:slack_userid => volunteer_slack_ids)
      new_volunteers = volunteers.reject{|v| self.active_volunteer_ids.include?(v.id)}
      volunteerings = new_volunteers.map{|v| self.volunteerings.build(user_id: v.id)}
      volunteerings.each do |v|
        v.skip_sending_volunteering_updates = true
        v.set_active!(ENV['AASM_OVERRIDE'])
        v.skip_sending_volunteering_updates = false
      end
      if volunteer_slack_ids.size > volunteers.size
        missing = volunteer_slack_ids - volunteers.map(&:slack_userid).compact
        self.flags += missing.map { |m| "volunteer slack id #{m} has no corresponding user" }
      end
    end

    if !airtable_project.progcode_coordinators.present?
      self.flags << "this project lacks a coordinator"
    else
      airtable_project.progcode_coordinators.each do |coord|
        coordinator = User.where(slack_username: coord["Slack Handle"].gsub("@", "")).first
        unless coordinator.present?
          self.flags << "progcode coordinator slack handle #{coord["Slack Handle"]} has no corresponding user"
        else
          self.progcode_coordinator_ids << coordinator.id
        end
      end
    end
    self.progcode_coordinator_ids = self.progcode_coordinator_ids.uniq

    airtable_project["Needs Categories"].each do |category|
      skill = Skill.where('lower(name) = ?', category.downcase).first_or_create(:name=>category, :tech=>nil)
      self.needs_categories << skill unless self.needs_categories.include?(skill)
    end unless airtable_project["Needs Categories"].blank?
    
    if airtable_project["Tech Stack"].blank?
      self.flags << "this project lacks a tech stack"
    else
      airtable_project["Tech Stack"].each do |tech|
        tech_skill = Skill.where('lower(name) = ?', tech.downcase).first_or_create(:name=>tech, :tech=>true)
        self.tech_stack << tech_skill unless self.tech_stack.include?(tech_skill)
      end
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

    airtable_project.master_channel_lists.each do |channel|
      self.master_channel_list << channel["Channel Name"]
    end unless airtable_project.master_channel_lists.blank?
    self.master_channel_list = self.master_channel_list.uniq.compact
    
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
  end

  def build_attributes(airtable_project)
    {
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