class Hooks::ZapierController < ApplicationController
  before_action -> { doorkeeper_authorize! :write }

  def airtable_update_project
   
  end

  def airtable_create_project
    project = Project.new
    
    if project_params[:status].blank?
      project.flags << "this project lacks a status"
    else
      project_params[:status].each do |status|
        project.status << status
      end
    end
    project.status = project.status.uniq

    if project_params[:project_lead_slack_id].blank?
      project.flags << "this project lacks a lead"
    else
      project_params[:project_lead_slack_id].split(', ').each do |slack_id|
        lead = User.find_by(:slack_userid => slack_id)
        if lead == nil
          project.flags << "project lead slack id #{slack_id} has no corresponding user"
        else
          project.lead_ids << lead.id
        end
      end
    end
    project.lead_ids = project.lead_ids.uniq

    if !project_params[:team_member_ids].blank?
      volunteer_slack_ids = project_params[:team_member_ids].split(', ').reject {|x| !project_params[:project_lead_slack_id].blank? && project_params[:project_lead_slack_id].split(', ').include?(x)}
      volunteers = User.where(:slack_userid => volunteer_slack_ids)
      project.volunteers += volunteers
      project.volunteers = project.volunteers.uniq
      project.volunteerings.reject{|v| v.state == "active"}.each {|v| v.set_active!(ENV['AASM_OVERRIDE'])}
      if project_params[:team_member_ids].split(', ').size != volunteers.size
        missing = volunteer_slack_ids - volunteers.map(&:slack_userid).compact
        project.flags += missing.map { |m| "volunteer slack id #{m} has no corresponding user" }
      end
    end

    if project_params[:progcode_coordinator_ids].blank?
      project.flags << "this project lacks a coordinator"
    else
      project_params[:progcode_coordinator_ids].split(', ').each do |coord_id|
        coordinator = User.find_by(:slack_userid => coord_id)
        if coordinator == nil
          project.flags << "progcode coordinator slack id #{coord_id} has no corresponding user"
        else
          project.progcode_coordinator_ids << coordinator.id
        end
      end
    end
    project.progcode_coordinator_ids = project.progcode_coordinator_ids.uniq

    project_params[:needs_categories].split(', ').each do |category|
      skill = Skill.where('lower(name) = ?', category.downcase).first_or_create(:name=>category, :tech=>nil)
      project.needs_categories << skill unless project.needs_categories.include?(skill)
    end unless project_params[:needs_categories].blank?
    
    if project_params[:tech_stack].blank?
      project.flags << "this project lacks a tech stack"
    else
      project_params[:tech_stack].split(', ').each do |tech|
        tech_skill = Skill.where('lower(name) = ?', tech.downcase).first_or_create(:name=>tech, :tech=>true)
        project.tech_stack << tech_skill unless project.tech_stack.include?(tech_skill)
      end
    end

    byebug

    if project_params.column_mappings.include?(:master_channel_list)
      project_params[:master_channel_list].split(', ').each do |channel|
        project.master_channel_list << channel[:channel_name]
      end unless project_params[:master_channel_list].blank?
      project.master_channel_list = project.master_channel_list.uniq.compact
    end
    
    project.assign_attributes(build_attributes(project_params))

    if project_params[:slack_channel]
      project.get_slack_channel_id(project_params[:slack_channel][0][:channel_name])
    end

    if project_params[:name].blank?
      project.flags << "this project lacks a name"
    end
    if project.legal_structures.blank?
      project.flags << "this project lacks a legal structure"
    end
    if project.progcode_github_project_link == nil
      project.flags << "this project lacks a link to a github repository"
    end

    project.mission_aligned = true
    project.flags.uniq!

    byebug 
    project.save(:validate => false)

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
    params.require(:zapier).permit(:name, :project_summary_text, :website, :slack_channel, :active_contributors, :airtable_id, :project_created, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :slack_channel_url, :software_license_url, :values_screening, :working_doc, :full_release_features, :attachments,  :needs_categories, :tech_stack, :business_models, :legal_structures, :oss_license_types, :project_applications,  :project_lead_slack_id, :master_channel_list, :team_member_ids, :progcode_coordinator_ids, :status => [])
  end

  def build_attributes(project_params)
    {
      description: project_params[:project_summary_text], slack_channel: extract_assoc(project_params, :slack_channel, :channel_name).join(","), project_created: project_params[:project_created]
    }.merge(extract_fields(project_params))
  end
  
  def extract_assoc(proj, key, field)
    return [] if proj[key].blank?
    proj[key].map {|obj| obj[field] }
  end
  
  def extract_fields(proj)
    hsh = {}.tap do |h|
      project.column_mappings.keys.each do |key|
        next if Project.column_for_attribute(key).table_name.blank?
        if proj[key].is_a?(Array) && (!Project.column_for_attribute(key).array)
          h[key] = proj[key].first
        else
          h[key] = proj[key]
        end
      end
    end.except(
      :name, :project_summary_text,
      :progcode_coordinator_ids, :tech_stack, :status, :team_member_ids,
      :project_lead_slack_id, :slack_channel, :needs_categories, :project_created, :master_channel_list
    )
  end

  
end
