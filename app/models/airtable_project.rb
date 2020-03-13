Airrecord.api_key = ENV['AIRTABLE_API_KEY']


class AirtableChannelList < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = "Channel List"
end

class AirtableProject < Airrecord::Table
  self.base_key = ENV['AIRTABLE_BASE_KEY']
  self.table_name = "Projects"
  has_many :slack_channels, class: 'AirtableChannelList', column: "Slack Channel"
  has_many :master_channel_lists, class: 'AirtableChannelList', column: "Master Channel List"
  has_many :progcode_coordinators, class: 'AirtableBaseManager', column: "ProgCode Coordinator(s)"
  has_many :project_leads, class: 'AirtableUser', column: "Project Lead"
  has_many :members, class: 'AirtableUser', column: "Team Member"
end