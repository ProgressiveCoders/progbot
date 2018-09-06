require_relative '../../config/environment'
require_relative '../../app/models/user'
require_relative '../../app/models/airtable_user'
require_relative '../../app/models/slack_bot'

module ImportUsersTask
  class Syncer
    def sync
      AirtableUser.all.each do |airtable_user|
        # Have we already imported this user?
        # I'll assume all names are last, first middle, so we
        # don't have to convert
        if airtable_user[:contact_e_mail].blank?
          puts "Email not in record: #{airtable_user.inspect}"
          next
        end
        user = User.find_or_initialize_by email: airtable_user[:contact_e_mail]

        tech_skills = Skill.where(name: airtable_user[:tech_skills], tech: true)
        non_tech_skills = Skill.where(name: airtable_user[:non_tech_skills_and_specialties], tech: false)
        user.assign_attributes(
          tech_skills: tech_skills,
          non_tech_skills: non_tech_skills,
          email: airtable_user[:contact_e_mail],
          slack_username: airtable_user[:slack_username],
          optin: true
        )
        user.save(:validate => false)
      end
    end
    
    def sync_slack_ids_for_users
      SlackBot.client
      User.all.each do |u|
        next if u.email.blank? || u.slack_userid.present?
        slack_user = SlackBot.lookup_by_email(u.email.downcase)
        next if slack_user.blank?
        u.slack_userid = slack_user.id
        u.save(:validate => false)
      end
    end
  end
end
