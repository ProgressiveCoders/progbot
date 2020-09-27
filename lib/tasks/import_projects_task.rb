require_relative '../../config/environment'
# require_relative '../../app/models/user'
# require_relative '../../app/models/project'
# require_relative '../../app/models/airtable_project'

module ImportProjectsTask
  class Syncer
    def sync
      
      AirtableProject.all.each do |airtable_project|
        next if airtable_project["Project Name"].blank?
        puts ("-" * 10) + "STARTING IMPORT FOR" + ("-" * 10)
        pp airtable_project
        puts ("-" * 20)

        if Project.where(airtable_id: airtable_project.id).present?
          proj = Project.find_by(airtable_id: airtable_project.id)
        else
          proj = Project.find_or_initialize_by name: airtable_project["Project Name"]
        end

        proj.sync_with_airtable(airtable_project)
      end
    end
  end
end
