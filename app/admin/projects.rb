ActiveAdmin.register Project do
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

  permit_params :name, :status, :description, :website,
                :slack_channel, skill_ids: [], volunteer_ids: [], lead_ids: []

  index do
    selectable_column
    column :name
    column :status
    column :description do |project|
      span project.description.try(:truncate, 30), :title => project.description
    end
    column :lead do |project|
      project.leads.map(&:name).to_sentence
    end
    column :website do |project|
      project.website.try(:truncate, 20)
    end
    column :slack_channel
    column :stacks do |project|
      span project.stacks.map(&:name).to_sentence
    end
    column :users do |project|
      c = project.users.count
      span "#{c} volunteer#{c == 1 ? '' : 's'}"
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :status
      row :description
      row :website
      row :slack_channel
      row :lead do
        span project.leads.map(&:name).to_sentence
      end
      row "Skills" do
        span project.skills.map(&:name).to_sentence
      end
      row :volunteers do
        span project.volunteers.map(&:name).to_sentence
      end
    end
  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
      f.input :status
      f.input :description
      f.input :website
      f.input :slack_channel
    end

    f.inputs "Selections" do
      f.input :lead_ids, :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :skills, :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :volunteers, :input_html => { multiple: true, size: 60, class: 'select2' }
    end
    f.actions
  end
end
