require_relative '../../config/environment'
require_relative '../../app/models/user'
require_relative '../../app/models/airtable_user'

module ImportUsersTask
  class Syncer
    def sync
      AirtableUser.all.each do |airtable_user|
        # Have we already imported this user?
        # I'll assume all names are last, first middle, so we
        # don't have to convert
        user = User.find_or_create_by name: airtable_user[:name]
        next unless user.tech_skills.empty?
        tech_skills = Skill.where(name: airtable_user[:tech_skills], tech: true)
        non_tech_skills = Skill.where(name: airtable_user[:non_tech_skills_and_specialties], tech: false)
        user.update(tech_skills: tech_skills,
                    non_tech_skills: non_tech_skills,
                    email: airtable_user[:contact_e_mail],
                    slack_username: airtable_user[:slack_username],
                    optin: true)
      end
    end
  end
end
