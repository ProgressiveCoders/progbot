Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class AirtableUser < Airrecord::Table

  self.base_key = "appjVs0ivEdT4He4N"
  self.table_name = "ProgBot Member Opt-In"
end
