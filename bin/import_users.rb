require_relative '../lib/task/import_users_task'

Airrecord.api_key = ENV['AIRTABLE_KEY']

ImportUsersTask.new.call
