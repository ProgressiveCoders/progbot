Airrecord.api_key = ENV['AIRTABLE_API_KEY']


class AirtableChannelList < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = ENV['AIRTABLE_CHANNEL_LIST_TABLE_NAME']
end