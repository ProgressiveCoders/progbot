ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# "welcome_email_sent", "attended_onboarding", "slack_invite_sent", "requested_additional_verification", "decline_membership", "irs_email_sent", "internal_notes", "contributor", "referrer_name", "skills_and_experience"
# end

permit_params :referer_id, :name, :email, :join_reason, :overview, :location,
:anonymous, :phone, :slack_username, :read_manifesto,
:read_code_of_conduct, :optin, :hear_about_us, :verification_urls, :is_approved, :additional_info, :welcome_email_sent, :attended_onboarding, :slack_invite_sent, :requested_additional_verification, :decline_membership, :irs_email_sent, :internal_notes, :contributor, :referrer_name, :skills_and_experience, :gender_pronouns, tech_skill_ids: [], non_tech_skill_ids: [], flags: [] 

action_item :bulk_import do
  link_to "Bulk Import From Airtable", admin_users_upload_csv_path
end


  index do
    selectable_column
    column :name
    column :slack_username
    column :email
    column :skills do |user|
      user.skills.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
    end
    column :flagged?
    column :updated_at

    actions
  end

  filter :name
  filter :slack_username
  filter :email
  filter :location, as: :select, collection: User.pluck(:location).compact.uniq, input_html: { multiple: true }
  filter :tech_skills, input_html: { multiple: true }
  filter :non_tech_skills, input_html: { multiple: true }
  filter :anonymous, label: "Anonymous?"
  filter :read_manifesto, label: "Read Manifesto?"
  filter :read_code_of_conduct, label: "Read Code of Conduct?"
  filter :optin, label: "Opted Into Skills Search?"
  filter :is_approved, label: "Approved?"
  filter :welcome_email_sent
  filter :attended_onboarding
  filter :slack_invite_sent
  filter :requested_additional_verification
  filter :decline_membership
  filter :irs_email_sent
  filter :contributor
  filter :referer, collection: User.where(id: User.pluck(:referer_id).compact.uniq)
  filter :gender_pronouns, as: :select, collection: UserConstants::GENDER_PRONOUNS, input_html: { multiple: true }
  filter :by_flagged_in, label: "Flagged?", as: :select, collection: %w[Yes No]
  filter :created_at
  filter :updated_at


  show do
    attributes_table do
      row :name
      row :slack_username
      row :email
      row :location
      row "Tech Skills" do
        span user.tech_skills.map(&:name).to_sentence
      end
      row "Non Tech Skills" do
        span user.non_tech_skills.map(&:name).to_sentence
      end
      row :phone
      row :referer
      row :join_reason
      row :overview
      row :hear_about_us
      row :referrer_name
      row :skills_and_experience
      row :verification_urls
      row :gender_pronouns
      row :additional_info
      row :anonymous
      row "Opt into skills search" do |u|
        u.optin
      end
      row :read_manifesto
      row :read_code_of_conduct
      row :is_approved
      row :welcome_email_sent
      row :attended_onboarding
      row :slack_invite_sent
      row :requested_additional_verification
      row :decline_membership
      row :irs_email_sent
      row :contributor
      row :internal_notes
      row :flags do
        span user.flags.try(:join, "<br>").try(:html_safe)
      end
    end
  end

  controller do

    def create
      resource.assign_attributes(permitted_params['user'])
      resource.flags.reject!(&:empty?)
      resource.save(:validate => false)
      redirect_to admin_user_path(resource)
    end

    def update
      resource.assign_attributes(permitted_params['user'])
      resource.flags.reject!(&:empty?)
      resource.save(:validate => false)
      redirect_to admin_user_path(resource)
    end

    def upload_csv

    end

    def import_data
      @users = []
      @attributes = UserConstants::COLUMN_NAMES_FOR_DISPLAY
      CSV.foreach(params[:file].path, headers: true) do |row|
        table_type = params["airtable_type"]
        airtable_id = row["Record ID"]
        if row[0].present?
        
          if table_type == "admin"
            airtable_user = AirtableUserFromAdmin.find(airtable_id)
            user = User.find_or_initialize_by(email: airtable_user["Contact E-Mail"])
          elsif table_type == "prog_apps"
            airtable_user = AirtableUser.find(airtable_id)
            user = User.where(airtable_id: airtable_id).first
            if user.blank?
              user = User.find_or_initialize_by(email: airtable_user["Contact E-Mail"])
            end
            user.airtable_id = airtable_id
          end
          user.sync_with_airtable(airtable_user, table_type)
          @users << user
        end
      end

      render 'import_success'
    end

  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
      f.input :email
      f.input :slack_username
      f.input :location
      f.input :phone
      f.input :referrer_name
      f.input :referer
      f.input :gender_pronouns, as: :select, collection: UserConstants::GENDER_PRONOUNS
    end

    f.inputs "Essay Questions" do
      f.input :join_reason
      f.input :overview
      f.input :hear_about_us
      f.input :skills_and_experience
      f.input :additional_info
    end

    f.inputs "Skills" do
      f.input :tech_skills, :collection => Skill.tech_skills, :input_html => { multiple: true, size: 60, class: 'select2' }
      f.input :non_tech_skills, :collection => Skill.non_tech_skills, :input_html => { multiple: true, size: 60, class: 'select2' }
    end

    f.inputs "Flags" do
      f.input :anonymous
      f.input :optin, label: "Opt into skills search"
      f.input :read_manifesto
      f.input :read_code_of_conduct
      user.flags.each do |flag|
        f.input :flags, :label => false, :input_html => {value: flag, name: 'user[flags][]'}
      end
      f.input :flags, :label => false, :input_html => {value: '', placeholder: 'Flag an issue with this user', name: 'user[flags][]'}
    end

    f.inputs "Admin Approval" do
      f.input :is_approved, label: "Is This An Approved Progcode Member?"
      f.input :verification_urls
      f.input :welcome_email_sent
      f.input :attended_onboarding
      f.input :slack_invite_sent
      f.input :requested_additional_verification
      f.input :decline_membership
      f.input :irs_email_sent
      f.input :contributor
      f.input :internal_notes

    end

    f.actions
  end
end
