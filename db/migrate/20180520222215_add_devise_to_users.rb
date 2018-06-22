class AddDeviseToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|

      ## Database authenticatable
      t.change :email, :string,     :null => false, :default => ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
     t.datetime :remember_created_at

     ## Trackable
     t.integer  :sign_in_count, default: 0, null: false
     t.datetime :current_sign_in_at
     t.datetime :last_sign_in_at
     t.inet     :current_sign_in_ip
     t.inet     :last_sign_in_ip

     ## OmniAuthable
     t.string :provider
     t.string :uid

   end

   add_index :users, :email, unique: true
   add_index :users, :reset_password_token, unique: true
  end
end
