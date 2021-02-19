class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :welcome_email_sent, :boolean
    add_column :users, :attended_onboarding, :boolean
    add_column :users, :slack_invite_sent, :boolean
    add_column :users, :requested_additional_verification, :boolean
    add_column :users, :decline_membership, :boolean
    add_column :users, :irs_email_sent, :boolean
    add_column :users, :internal_notes, :text
    add_column :users, :contributor, :boolean
    add_column :users, :referrer_name, :string
    add_column :users, :skills_and_experience, :text
  end
end
