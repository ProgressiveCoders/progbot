class Hooks::ZapierController < ApplicationController
  before_action -> { doorkeeper_authorize! :write }

  def airtable_update_project
   
  end

  def airtable_create_project
    airtable_project = AirtableProject.find(project_params[:airtable_id])
    
    project = Project.new(airtable_id: airtable_project.id)
    project.skip_new_project_notification_email = true

    sync_attributes(airtable_project, project)

    render json: {message: "Project #{project.id} successfully created"}
  end
  
  def airtable_update_user

  end

  def airtable_create_user

  end

  def home
    render json: {message: "You are Home"}.to_json
  end

  private

  def current_resource_owner
    HookUser.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
  
  def current_hook_user
    current_resource_owner
  end

  def authenticate_scope!
    self.resource = send(:"current_#{resource_name}")
  end

  def project_params
    params.require(:zapier).permit(:airtable_id)
  end

  def build_attributes(project_params)
    {
      description: project_params["Project Summary TEXT"], 
      needs_pain_points_narrative: project_params["Needs / Pain Points - Narrative"],
      legal_structures: project_params["Legal structure"],
      active_contributors: project_params["Active Contributors (full time equivalent)"],
      business_models: project_params["Business model"],
      oss_license_types: project_params["OSS License Type"]
    }.merge(extract_fields(project_params))
  end
  
  def extract_assoc(proj, key, field)
    return [] if proj[key].blank?
    proj[key].map {|obj| obj[field] }
  end
  
  def extract_fields(proj)
    hsh = {}.tap do |h|
      extracted_fields = proj.fields.keys -         ["Project Name", "Project Summary Text",
        "Progcode Coordinator IDs", "Tech Stack", "Project Status", "Team Member IDs",
        "Project Lead Slack ID", "Slack Channel", "Needs Categories", "Master Channel List", "Needs / Pain Points - Narrative", "Legal structure", "Active Contributors (full time equivalent)", "Business model", "OSS License Type"]
      extracted_fields.each do |key|
        downcased_key = key.downcase.gsub(" ", "_")
        next if Project.column_for_attribute(downcased_key).table_name.blank?
        if proj[key].is_a?(Array) && (!Project.column_for_attribute(downcased_key).array)
          h[downcased_key] = proj[key].first
        else
          h[downcased_key] = proj[key]
        end
      end
    end
  end

  def sync_attributes(airtable_project, proj)
    if airtable_project["Project Name"].blank?
      proj.flags << "this project lacks a name"
    else
      proj.name = airtable_project["Project Name"]
    end
    
    if airtable_project["Project Status"].blank?
      proj.flags << "this project lacks a status"
    else
      airtable_project["Project Status"].each do |status|
        proj.status << status
      end
    end
    proj.status = proj.status.uniq

    if !airtable_project.project_leads.present?
      proj.flags << "this project lacks a lead"
    else
      airtable_project.project_leads.each do |project_lead|
        slack_id = project_lead["slack_id"]
        lead = User.find_by(:slack_userid => slack_id)
        if lead == nil
          proj.flags << "project lead slack id #{slack_id} has no corresponding user"
        else
          proj.lead_ids << lead.id
        end
      end
    end
    proj.lead_ids = proj.lead_ids.uniq

    if airtable_project.members.present?
      slack_ids = airtable_project.members.pluck("slack_id")
      volunteer_slack_ids = slack_ids.reject {|x| airtable_project.project_leads.pluck("slack_id").include?(x)}
      volunteers = User.where(:slack_userid => volunteer_slack_ids)
      proj.volunteers += volunteers
      proj.volunteers = proj.volunteers.uniq
      proj.volunteerings.reject{|v| v.state == "active"}.each {|v| v.set_active!(ENV['AASM_OVERRIDE'])}
      if volunteer_slack_ids.size > volunteers.size
        missing = volunteer_slack_ids - volunteers.map(&:slack_userid).compact
        proj.flags += missing.map { |m| "volunteer slack id #{m} has no corresponding user" }
      end
    end

    if !airtable_project.progcode_coordinators.present?
      proj.flags << "this project lacks a coordinator"
    else
      airtable_project.progcode_coordinators.each do |coord|
        user = User.where(slack_username: coord["Slack Handle"].gsub("@", "")).first
        coord_id = user["slack_id"]
        coordinator = User.find_by(:slack_userid => coord_id)
        if coordinator == nil
          proj.flags << "progcode coordinator slack id #{coord_id} has no corresponding user"
        else
          proj.progcode_coordinator_ids << coordinator.id
        end
      end
    end
    proj.progcode_coordinator_ids = proj.progcode_coordinator_ids.uniq

    airtable_project["Needs Categories"].each do |category|
      skill = Skill.where('lower(name) = ?', category.downcase).first_or_create(:name=>category, :tech=>nil)
      proj.needs_categories << skill unless proj.needs_categories.include?(skill)
    end unless airtable_project["Needs Categories"].blank?
    
    if airtable_project["Tech Stack"].blank?
      proj.flags << "this project lacks a tech stack"
    else
      airtable_project["Tech Stack"].each do |tech|
        tech_skill = Skill.where('lower(name) = ?', tech.downcase).first_or_create(:name=>tech, :tech=>true)
        proj.tech_stack << tech_skill unless proj.tech_stack.include?(tech_skill)
      end
    end

    airtable_project.slack_channels.each do |channel|
      proj.slack_channel = channel["Channel Name"]
    end unless !airtable_project.slack_channels.present?

    airtable_project.master_channel_lists.each do |channel|
      proj.master_channel_list << channel["Channel Name"]
    end unless !airtable_project.master_channel_lists.present?
    proj.master_channel_list = proj.master_channel_list.uniq.compact
    
    proj.assign_attributes(build_attributes(airtable_project))

    if airtable_project.slack_channels.present?
      proj.get_slack_channel_id(airtable_project.slack_channels.first["Channel Name"])
    end

    if proj.legal_structures.blank?
      proj.flags << "this project lacks a legal structure"
    end
    if proj.progcode_github_project_link == nil
      proj.flags << "this project lacks a link to a github repository"
    end

    proj.mission_aligned = true
    proj.flags.uniq!
    proj.save(:validate => false)

  end

  
end
