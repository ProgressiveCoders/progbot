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
        proj.leads = User.where(:slack_userid => airtable_project[:project_lead_slack_id]) unless airtable_project[:project_lead_slack_id].blank?
        proj.volunteers += User.where(:slack_userid => airtable_project[:team_member_ids]) unless airtable_project[:team_member_ids].blank?
        proj.skills = Skill.match_skills(airtable_project[:tech_stack]).tech_skills unless airtable_project[:tech_stack].blank?
        proj.assign_attributes(build_attributes(airtable_project))
        proj.save(:validate => false)
      end
    end
    
    def build_attributes(airtable_project)
      {
        description: airtable_project[:project_summary_text],
        active_contributors: airtable_project[:active_contributors_full_time_equivalent_],
        progcode_coordinator: extract_assoc(airtable_project, :progcode_coordinator_s_, :name).join(","),
        project_lead_slack_id: airtable_project[:project_lead_slack_id].try(:join, ","),
        team_member_ids: airtable_project[:team_member_ids].try(:join, ","),
        slack_channel: extract_assoc(airtable_project, :slack_channel, :channel_name).join(","),
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
        :progcode_coordinator_s_, :team_member, :tech_stack, :project_status, :team_member_ids,
        :project_lead_slack_id, :slack_channel
      )
    end
  end
end