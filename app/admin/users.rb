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

  controller do

  end
  
  permit_params :referer_id, :name, :email, :join_reason, :overview, :location,
                :anonymous, :phone, :slack_username, :read_manifesto,
                :read_code_of_conduct, :optin, skill_ids: []

  index do
    selectable_column
    column :name
    column :slack_username
    column :email
    column :tech_skills do |user|
      user.tech_skills.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
    end

    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :location
      row :phone
      row :slack_username
      row :referer
      row :join_reason
      row :overview
      row "Tech Skills" do
        span user.tech_skills.map(&:name).to_sentence
      end
      row :anonymous
      row :optin, label: "Opt into skills search"
      row :read_manifesto
      row :read_code_of_conduct
    end
  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
      f.input :email
      f.input :location
      f.input :phone
      f.input :slack_username
      f.input :referer
    end

    f.inputs "Essay Questions" do
      f.input :join_reason
      f.input :overview
      f.input :tech_skills, :input_html => { multiple: true, size: 30, class: 'select2' }
    end

    f.inputs "Flags" do
      f.input :anonymous
      f.input :optin, label: "Opt into skills search"
      f.input :read_manifesto
      f.input :read_code_of_conduct
    end

    f.actions
  end
end
