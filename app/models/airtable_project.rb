Airrecord.api_key = ENV['AIRTABLE_API_KEY']


class AirtableChannelList < Airrecord::Table
  self.base_key = "appwE2GxYI3JzuGix"
  self.table_name = "Channel List"
end

class AirtableBaseManager < Airrecord::Table
  self.base_key = "appwE2GxYI3JzuGix"
  self.table_name = "Base Managers"
end

class AirtableMember < Airrecord::Table
  self.base_key = "appwE2GxYI3JzuGix"
  self.table_name = "Members"
end


class AirtableProject < Airrecord::Table
  self.base_key = "appwE2GxYI3JzuGix"
  self.table_name = "Projects"
  has_many :slack_channels, class: 'AirtableChannelList', column: "Slack Channel"
  has_many :master_channel_lists, class: 'AirtableChannelList', column: "Master Channel List"
  has_many :progcode_coordinators, class: 'AirtableBaseManager', column: "ProgCode Coordinator(s)"
  has_many :project_leads, class: 'AirtableMember', column: "Project Lead"
  has_many :members, class: 'AirtableMember', column: "Team Member"
end