class AddingUserformColumns < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :hear_about_us, :text
    add_column :users, :verification_urls, :text
  end
end