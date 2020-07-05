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
        proj = Project.find_or_initialize_by name: airtable_project["Project Name"]

        proj.sync_with_airtable(airtable_project)
      end
    end
  end
end
