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


        airtable_project[:project_lead_slack_id].each do |slack_id|
          lead = User.find_by(:slack_userid => slack_id)
          if lead != nil
            unless proj.lead_ids.include?(lead.id)
              proj.lead_ids << lead.id
            end
          end
        end unless airtable_project[:project_lead_slack_id].blank?

        airtable_project[:team_member_ids].each do |member_id|
          volunteer = User.find_by(:slack_userid => member_id)
          if volunteer != nil
            unless proj.volunteers.include?(volunteer)
              proj.volunteers << volunteer
            end
          end
        end unless airtable_project[:team_member_ids].blank?

        airtable_project[:progcode_coordinator_ids].each do |coord_id|
           coordinator = User.find_by(:slack_userid => coord_id)
           if coordinator != nil
             unless proj.progcode_coordinator_ids.include?(coordinator.id)
            proj.progcode_coordinator_ids << coordinator.id
           end
          end
        end unless airtable_project[:progcode_coordinator_ids].blank?

        airtable_project[:needs_categories].each do |category|
          skill = Skill.where('lower(name) = ?', category.downcase).first_or_create(:name=>category)
          unless proj.needs_categories.include?(skill)
            proj.needs_categories << skill
          end
        end unless airtable_project[:needs_categories].blank?

        proj.tech_skills = Skill.match_skills(airtable_project[:tech_stack]).tech_skills unless airtable_project[:tech_stack].blank?

        if airtable_project.column_mappings.include?(:master_channel_list)
          airtable_project[:master_channel_list].each do |channel|
            unless proj.master_channel_list.include?(channel[:channel_name])
              proj.master_channel_list << channel[:channel_name]
            end
          end unless airtable_project[:master_channel_list].blank?
        end

        proj.assign_attributes(build_attributes(airtable_project))
        proj.save(:validate => false)
      end

      
    end
    
    def build_attributes(airtable_project)
      {
        description: airtable_project[:project_summary_text], slack_channel: extract_assoc(airtable_project, :slack_channel, :channel_name).join(","),
        status: airtable_project[:project_status].try(:first) || "In Development"
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