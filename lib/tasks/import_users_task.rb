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
      if User.where(airtable_id: airtable_user.id).present?
        user = User.find_by(airtable_id: airtable_user.id)
      else
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
        if user.airtable_id.present? && AirtableUser.all.detect{|airtable_user| airtable_user.id == user.airtable_id}.present?
          next
        else
          user.airtable_id = airtable_user.id
        end
      end

        user.sync_with_airtable(airtable_user, 'prog apps')
      end
    end

    def admin_sync
      AirtableUserFromAdmin.all.each do |airtable_user|
        if airtable_user["Contact E-Mail"].blank?
          puts "Email not in record: #{airtable_user.inspect}"
          next
        else
          user = User.find_or_initialize_by email: airtable_user["Contact E-Mail"]

          user.sync_with_airtable(airtable_user, 'admin')
        end
      end
    end

  end
end
