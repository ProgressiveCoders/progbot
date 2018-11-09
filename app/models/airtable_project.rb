Airrecord.api_key = ENV['AIRTABLE_API_KEY']


class AirtableChannelList < Airrecord::Table
  self.base_key = "appUZignaw9kIHqTR"
  self.table_name = "Channel List"
end

class AirtableBaseManager < Airrecord::Table
  self.base_key = "appUZignaw9kIHqTR"
  self.table_name = "Base Managers"
end


class AirtableProject < Airrecord::Table
  self.base_key = "appUZignaw9kIHqTR"
  self.table_name = "Projects"
  has_many :slack_channels, class: 'AirtableChannelList', column: "Slack Channel"
  has_many :progcode_coordinators, class: 'AirtableBaseManager', column: "ProgCode Coordinator(s)"
  has_many :project_lead_slack_ids, column: "Project Lead Slack ID"
end