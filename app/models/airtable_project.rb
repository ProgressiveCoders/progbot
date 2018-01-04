Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class AirtableProject < Airrecord::Table
  self.base_key = "appSZ79o51JzNr3HP"
  self.table_name = "Projects"
end
