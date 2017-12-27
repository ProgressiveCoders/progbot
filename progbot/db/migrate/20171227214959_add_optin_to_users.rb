class AddOptinToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :optin, :boolean
  end
end
