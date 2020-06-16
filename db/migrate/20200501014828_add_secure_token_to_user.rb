class AddSecureTokenToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :secure_token, :string
    add_index :users, :secure_token, unique: true
  end
end
