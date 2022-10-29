ActiveAdmin.register Volunteering do
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

        def update
            case volunteering_params[:event]
            when 'set_active'
              resource.set_active!(ENV['AASM_OVERRIDE'])
            when 'set_former'
              resource.set_former!(ENV['AASM_OVERRIDE'])
            end
            redirect_to admin_volunteering_path
        end

        def volunteering_params
            params.require(:volunteering).permit(:event)
        end

    end
    begin
        filter :user, :label => "Volunteer", :collection => User.where(id: Volunteering.pluck(:user_id)).uniq.reject{|u| !u.admin_label || u.admin_label == ''}.sort_by{|u| u.admin_label.downcase}.map{ |u| u.admin_label }, :input_html => {multiple: true}

        filter :project, :collection => Project.where(id: Volunteering.pluck(:project_id)).uniq.sort_by{|p| p.name.downcase}, :input_html => {multiple: true}

        filter :state, as: :select, :collection => Volunteering.aasm.states.map(&:name).sort, :input_html => {multiple: true}

        filter :created_at
        filter :updated_at
    rescue ActiveAdmin::DatabaseHitDuringLoad
    end


    form do |f|
        f.input :project, :input_html => {disabled: true, readonly: true}
        f.input :user, :input_html => {disabled: true, readonly: true}
        f.input :state, :input_html => {disabled: true, readonly: true}
        f.input :event, label: 'Change State', collection: resource.aasm.events({permitted: true}, ENV['AASM_OVERRIDE']).map(&:name), :selected => volunteering.state, :input_html => {class: 'select2'}

        f.submit

    end

end
