class AddFlagsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :flags, :string, array: true, default: []
  end
end
