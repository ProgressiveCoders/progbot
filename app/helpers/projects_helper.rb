module ProjectsHelper

    def scrubbed_attributes(project)
        project.attributes.except('id', 'name', 'description', 'lead_ids', 'business_models', 'legal_structures', 'oss_license_types', 'project_applications', 'progcode_coordinator_ids', 'import_errors', 'master_channel_list', 'status', 'slack_channel', 'mission_aligned')
    end

    def contributor_attributes(project)
        project.slice('leads', 'volunteers', 'progcode_coordinators')
    end

end
