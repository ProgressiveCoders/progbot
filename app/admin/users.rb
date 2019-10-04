ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

permit_params :referer_id, :name, :email, :join_reason, :overview, :location,
:anonymous, :phone, :slack_username, :read_manifesto,
:read_code_of_conduct, :optin, :hear_about_us, :verification_urls, :is_approved, :gender_pronouns, :additional_info, tech_skill_ids: [], non_tech_skill_ids: []


  index do
    selectable_column
    column :name
    column :slack_username
    column :email
    column :skills do |user|
      user.skills.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
    end

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
  filter :referer, collection: User.where(id: User.pluck(:referer_id).compact.uniq)
  filter :gender_pronouns, as: :select, collection: UserConstants::GENDER_PRONOUNS, input_html: { multiple: true }
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
    end
  end

  controller do

    def create
      resource.assign_attributes(permitted_params['user'])
      resource.save(:validate => false)
      redirect_to admin_user_path(resource)
    end

    def update
      resource.assign_attributes(permitted_params['user'])
      resource.save(:validate => false)
      redirect_to admin_user_path(resource)
    end

  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
      f.input :email
      f.input :slack_username
      f.input :location
      f.input :phone
      f.input :referer
      f.input :gender_pronouns, as: :select, collection: UserConstants::GENDER_PRONOUNS, input_html: { multiple: true }
    end

    f.inputs "Essay Questions" do
      f.input :join_reason
      f.input :overview
      f.input :hear_about_us
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
    end

    f.inputs "Admin Approval" do
      f.input :is_approved, label: "Is This An Approved Progcode Member?"
      f.input :verification_urls
    end

    f.actions
  end
end
