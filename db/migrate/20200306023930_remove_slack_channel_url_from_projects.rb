class RemoveSlackChannelUrlFromProjects < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :slack_channel_url
  end
end
