module ProjectsHelper

    def scrubbed_attributes(project)
        project.attributes.except('id', 'name', 'description', 'lead_ids', 'business_models', 'legal_structures', 'oss_license_types', 'project_applications', 'progcode_coordinator_ids', 'flags', 'master_channel_list', 'status', 'slack_channel', 'slack_channel_id','mission_aligned', 'created_at').sort
    end

    def contributor_attributes(project)
        project.slice('leads', 'active_volunteers', 'progcode_coordinators')
    end

end
