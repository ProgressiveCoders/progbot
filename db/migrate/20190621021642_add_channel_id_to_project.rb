class AddChannelIdToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :slack_channel_id, :string
  end
end
