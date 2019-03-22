class AddStateToVolunteerings < ActiveRecord::Migration[5.1]
  def change
    add_column :volunteerings, :state, :string
  end
end
