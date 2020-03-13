Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class AirtableUser < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = "ProgbotTestMembers"

  has_one :airtable_base_manager, class: 'AirtableBaseManager', column: 'Base Managers'
end

class AirtableBaseManager < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = "Base Managers"

  belongs_to :airtable_user, class: 'AirtableUser', column: "MembersTableTwin"
end
