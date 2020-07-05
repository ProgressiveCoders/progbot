Airrecord.api_key = ENV['AIRTABLE_API_KEY']


class AirtableChannelList < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = ENV['AIRTABLE_CHANNEL_LIST_TABLE_NAME']
end

class AirtableProject < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = ENV['AIRTABLE_PROJECT_TABLE_NAME']
  belongs_to :slack_channel, class: 'AirtableChannelList', column: ENV['AIRTABLE_PROJECT_SLACK_CHANNEL_COLUMN']
  has_many :master_channel_lists, class: 'AirtableChannelList', column: ENV['AIRTABLE_PROJECT_MASTER_CHANNEL_COLUMN']
  has_many :progcode_coordinators, class: 'AirtableBaseManager', column: ENV['AIRTABLE_PROJECT_COORDINATORS_COLUMN']
  has_many :project_leads, class: 'AirtableUser', column: ENV['AIRTABLE_PROJECT_LEADS_COLUMN']
  has_many :members, class: 'AirtableUser', column: ENV['AIRTABLE_PROJECT_MEMBERS_COLUMN']
end