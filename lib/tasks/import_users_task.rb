require_relative '../../config/environment'
# require_relative '../../app/models/user'
# require_relative '../../app/models/airtable_user'
# require_relative '../../app/models/slack_bot'
require_relative '../slack_helpers'

module ImportUsersTask
  class Syncer
    def sync
      AirtableUser.all.each do |airtable_user|
        # Have we already imported this user?
        # I'll assume all names are last, first middle, so we
        # don't have to convert
        if airtable_user["slack_id"].blank?
          puts "Slack ID not in record: #{airtable_user.inspect}"
          if airtable_user["Contact E-Mail"].blank?
            puts "Email not in record: #{airtable_user.inspect}"
            next
          else
            user = User.find_or_initialize_by email: airtable_user["Contact E-Mail"]
          end
        else
          user = User.find_or_initialize_by slack_userid: airtable_user["slack_id"]
        end

        user.sync_with_airtable(airtable_user)
      end
    end
    
    def sync_slack_ids_for_users
      SlackBot.client
      User.all.each do |u|
        next if u.email.blank? || u.slack_userid.present?
        slack_user = SlackHelpers.lookup_by_email(u.email.downcase)
        next if slack_user.blank?
        u.slack_userid = slack_user.id
        u.save(:validate => false)
      end
    end
  end
end
