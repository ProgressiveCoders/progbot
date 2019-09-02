ActiveAdmin.register Skill do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
 permit_params :name, :tech
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

index do
  selectable_column
  column :id
  column :name
  column :created_at
  column :updated_at
  column "Tech Skill?", :tech do |skill|
    case skill.tech
    when true
      "Yes"
    when false
      "No"
    when nil
      "Unassigned"
    end
  end
  actions
end

filter :by_tech_designation_in, label: "Tech Skill?", as: :select, collection: %w[ Yes No Unassigned ]
filter :name_cont, label: 'Name'

form do |f|
  f.inputs do
    f.input :name
    f.input :tech, :label => "Tech Skill?", :as => :select
  end
  f.submit
end

show do
  attributes_table do
    row :name
    row :tech do
      skill.designate
    end
  end
end

end
