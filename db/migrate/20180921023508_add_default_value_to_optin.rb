class AddDefaultValueToOptin < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :optin, :boolean, default: true
  end
end
