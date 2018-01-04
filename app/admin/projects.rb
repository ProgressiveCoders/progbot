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

  permit_params :name, :status, :description, :lead_id, :website,
                :slack_channel, skill_ids: [], volunteer_ids: []

  index do
    selectable_column
    column :name
    column :status
    column :description
    column :lead do |project|
      project.lead.name
    end
    column :website
    column :slack_channel
    column :skills do |project|
      skill_list = []
      project.skills.each {|skill| skill_list.push(skill.name)}
      span skill_list.join(", ")
    end
    column :volunteers do |project|
      c = project.volunteers.count
      span "#{c} volunteer#{c == 1 ? '' : 's'}"
    end
    actions
  end

  show do
    skill_list = []
    project.skills.each { |skill| skill_list.push(skill.name) }
    volunteer_list = []
    project.volunteers.each { |volunteer| volunteer_list.push(volunteer.name) }
    attributes_table do
      row :name
      row :status
      row :description
      row :website
      row :slack_channel
      row :lead do
        span project.lead.name
      end
      row "Skills" do
        span skill_list.join(", ")
      end
      row :volunteers do
        span volunteer_list.join(", ")
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
      f.input :lead, :input_html => { multiple: false, size: 60, class: 'select2' }

      f.input :skills, :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :volunteers, :input_html => { multiple: true, size: 60, class: 'select2' }
    end
    f.actions
  end
end
