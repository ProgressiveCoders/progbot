Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class AirtableUser < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = ENV['AIRTABLE_USER_TABLE_NAME']

  has_one :airtable_base_manager, class: 'AirtableBaseManager', column: ENV['AIRTABLE_USER_MANAGERS_COLUMN']
end

class AirtableBaseManager < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = ENV['AIRTABLE_BASE_MANAGER_TABLE_NAME']

  belongs_to :airtable_user, class: 'AirtableUser', column: ENV['AIRTABLE_MANAGER_USER_COLUMN']
end
