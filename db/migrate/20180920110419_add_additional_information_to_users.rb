class AddAdditionalInformationToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :additional_info, :text
  end
end
