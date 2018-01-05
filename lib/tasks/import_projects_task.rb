require_relative '../../config/environment'
require_relative '../../app/models/user'
require_relative '../../app/models/project'
require_relative '../../app/models/airtable_project'

module ImportProjectsTask
  class Syncer
    def sync
      AirtableProject.all.each do |airtable_project|
        # Have we already imported this project?
        proj = Project.find_or_create_by name: airtable_project[:name]
        next unless proj.skills.empty?
        skills = Skill.where(name: airtable_project[:tech_skills], tech: true) +
                 Skill.where(name: airtable_project[:non_tech_skills_and_specialties], tech: false)
        user.update(skills: skills,
                    email: airtable_user[:contact_e_mail],
                    slack_username: airtable_user[:slack_username],
                    optin: true)
      end
    end
  end
end
