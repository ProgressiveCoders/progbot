Airrecord.api_key = ENV['AIRTABLE_API_KEY']

class AirUser < Airrecord::Table
  self.base_key = "app8W5ENzEPIh2ibG"
  self.table_name = "ProgBot Member Opt-In"
end
