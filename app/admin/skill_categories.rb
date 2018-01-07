ActiveAdmin.register SkillCategory do
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
  permit_params :name, skill_ids: []

  index do
    selectable_column
    column :name
    column :skills do |category|
      skill_list = []
      category.skills.each {|skill| skill_list.push(skill.name)}
      span skill_list.join(", ")
    end
    actions
  end

  show do
    skill_list = []
    skill_category.skills.each { |skill| skill_list.push(skill.name) }
    attributes_table do
      row :name
      row "Skills" do
        span skill_list.join(", ")
      end
    end
  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
    end

    f.inputs "Selections" do
      f.input :skills, :input_html => { multiple: true, size: 60, class: 'select2' }
    end
    f.actions
  end
end
