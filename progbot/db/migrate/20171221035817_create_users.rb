class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.text :join_reason
      t.text :overview
      t.string :location
      t.boolean :anonymous
      t.string :phone
      t.string :slack_username
      t.boolean :read_manifesto
      t.boolean :read_code_of_conduct
      t.references :referer, foreign_key: true

      t.timestamps
    end
  end
end
