class AddIsApprovedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :is_approved, :boolean
  end
end
