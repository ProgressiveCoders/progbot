require_relative '../../config/environment'
require_relative '../../app/models/user'
require_relative '../../app/models/project'
require_relative '../../app/models/airtable_project'

module ImportProjectsTask
  class Syncer
    def sync
      
      AirtableProject.all.each do |airtable_project|
        next if airtable_project[:project_name].blank?
        puts ("-" * 10) + "STARTING IMPORT FOR" + ("-" * 10)
        pp airtable_project
        puts ("-" * 20)
        proj = Project.find_or_initialize_by name: airtable_project[:project_name]

        proj.sync_with_airtable(airtable_project)
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
