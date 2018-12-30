class RemoveMasterChannelList < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :master_channel_list
    add_column :projects, :master_channel_list, :string, array: true, default: []
  end
end
