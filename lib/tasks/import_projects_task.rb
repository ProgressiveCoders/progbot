require_relative '../../config/environment'
require_relative '../../app/models/user'
require_relative '../../app/models/project'
require_relative '../../app/models/airtable_project'

module ImportProjectsTask
  class Syncer
    def sync
      
      AirtableProject.all.each do |airtable_project|
        # Have we already imported this project?
        next if airtable_project[:project_name].blank?
        puts ("-" * 10) + "STARTING IMPORT FOR" + ("-" * 10)
        pp airtable_project
        puts ("-" * 20)
        proj = Project.find_or_initialize_by name: airtable_project[:project_name]

        if airtable_project[:project_status].blank?
          proj.import_errors << "this project lacks a status"
        else
          airtable_project[:project_status].each do |status|
            proj.status << status
          end
        end
        proj.status = proj.status.uniq

        if airtable_project[:project_lead_slack_id].blank?
          proj.import_errors << "this project lacks a lead"
        else
          airtable_project[:project_lead_slack_id].each do |slack_id|
            lead = User.find_by(:slack_userid => slack_id)
            if lead == nil
              proj.import_errors << "project lead slack id #{slack_id} has no corresponding user"
            else
              proj.lead_ids << lead.id
            end
          end
        end
        proj.lead_ids = proj.lead_ids.uniq
        
        if !airtable_project[:team_member_ids].blank?
          volunteers = User.where(:slack_userid => airtable_project[:team_member_ids])
          proj.volunteers += volunteers
          proj.volunteers = proj.volunteers.uniq
          if airtable_project[:team_member_ids].size != volunteers.size
            missing = airtable_project[:team_member_ids] - volunteers.map(&:slack_userid).compact
            proj.import_errors += missing.map { |m| "volunteer slack id #{m} has no corresponding user" }
          end
        end


        if airtable_project[:progcode_coordinator_ids].blank?
          proj.import_errors << "this project lacks a coordinator"
        else
          airtable_project[:progcode_coordinator_ids].each do |coord_id|
            coordinator = User.find_by(:slack_userid => coord_id)
            if coordinator == nil
              proj.import_errors << "progcode coordinator slack id #{coord_id} has no corresponding user"
            else
              proj.progcode_coordinator_ids << coordinator.id
            end
          end
        end
        proj.progcode_coordinator_ids = proj.progcode_coordinator_ids.uniq

        airtable_project[:needs_categories].each do |category|
          skill = Skill.where('lower(name) = ?', category.downcase).first_or_create(:name=>category, :tech=>nil)
          proj.needs_categories << skill unless proj.needs_categories.include?(skill)
        end unless airtable_project[:needs_categories].blank?
        
        if airtable_project[:tech_stack].blank?
          proj.import_errors << "this project lacks a tech stack"
        else
          airtable_project[:tech_stack].each do |tech|
            tech_skill = Skill.where('lower(name) = ?', tech.downcase).first_or_create(:name=>tech, :tech=>true)
            proj.tech_stack << tech_skill unless proj.tech_stack.include?(tech_skill)
          end
        end

        if airtable_project.column_mappings.include?(:master_channel_list)
          airtable_project[:master_channel_list].each do |channel|
            proj.master_channel_list << channel[:channel_name]
          end unless airtable_project[:master_channel_list].blank?
          proj.master_channel_list = proj.master_channel_list.uniq.compact
        end

        proj.assign_attributes(build_attributes(airtable_project))

        if airtable_project[:project_name].blank?
          proj.import_errors << "this project lacks a name"
        end
        if proj.legal_structures.blank?
          proj.import_errors << "this project lacks a legal structure"
        end
        if proj.progcode_github_project_link == nil
          proj.import_errors << "this project lacks a link to a github repository"
        end

        proj.mission_aligned = true
        proj.import_errors.uniq!
        proj.save(:validate => false)
      end
    end
    
    def build_attributes(airtable_project)
      {
        description: airtable_project[:project_summary_text], slack_channel: extract_assoc(airtable_project, :slack_channel, :channel_name).join(","), project_created: airtable_project[:project_created]
      }.merge(extract_fields(airtable_project))
    end
    
    def extract_assoc(proj, key, field)
      return [] if proj[key].blank?
      proj[key].map {|obj| obj[field] }
    end
    
    def extract_fields(proj)
      hsh = {}.tap do |h|
        proj.column_mappings.keys.each do |key|
          next if Project.column_for_attribute(key).table_name.blank?
          if proj[key].is_a?(Array) && (!Project.column_for_attribute(key).array)
            h[key] = proj[key].first
          else
            h[key] = proj[key]
          end
        end
      end.except(
        :project_name, :project_summary_text, :active_contributors_full_time_equivalent_,
        :team_member, :project_lead_slack_contact, :members, :team_member_name_s_,
        :progcode_coordinator_s_, :progcode_coordinator_ids, :team_member, :tech_stack, :project_status, :team_member_ids,
        :project_lead_slack_id, :slack_channel, :needs_categories, :project_created, :master_channel_list
      )
    end
  end
end