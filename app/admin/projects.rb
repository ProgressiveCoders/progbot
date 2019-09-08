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
                :slack_channel, :mission_aligned, :skill_ids => [], :volunteer_ids => [], :lead_ids => [], :progcode_coordinator_ids => [], :volunteerings_attributes => [:user_id]

  index do
    selectable_column
    column :name
    column :status do |project|
      project.status.join(', ')
    end
    column :description do |project|
      span project.description.try(:truncate, 30), :title => project.description
    end
    column :leads do |project|
      project.leads.map(&:slack_username).to_sentence
    end
    column :progcode_coordinators do |project|
      project.progcode_coordinators.map(&:slack_username).to_sentence
    end
    column :volunteers do |project|
      c = project.volunteers.count
      span "#{c} volunteer#{c == 1 ? '' : 's'}"
    end
    column :slack_channel do |project|
      if project.slack_channel
        if project.slack_channel_id
          link_to '#' + project.slack_channel, 'slack://channel?team=T1KR8AG7J&id=' + project.slack_channel_id
        else
          project.slack_channel
        end
      end
    end
    column :stacks do |project|
      project.stacks.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
    end
    column :mission_aligned
    column :flagged?
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :status do
        span project.status.join(', ')
      end
      row :mission_aligned
      row :description
      row :website
      row :repository
      row :progcode_github_project_link
      row :slack_channel
      row :leads do
        span project.leads.map(&:slack_username).to_sentence
      end
      row :progcode_coordinators do
        span project.progcode_coordinators.map(&:slack_username).to_sentence
      end
      row :volunteers do
        span project.volunteerings.map{|v| v.nested_label}.to_sentence
      end
      row "Tech Stack" do
        span project.tech_stack.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
      end
      row "Non Tech Stack" do
        span project.non_tech_stack.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
      end
      row "Needs Categories" do
        span project.needs_categories.map { |s| link_to s.name, admin_skill_path(s) }.join(', ').html_safe
      end
      row :mission_accomplished
      row :full_release_features
      row :needs_pain_points_narrative
      row :project_applications do
        span project.project_applications.join(', ')
      end
      row :active_contributors
      row :org_structure
      row :legal_structures do
        span project.legal_structures.join(', ')
      end
      row :oss_license_types do
        span project.oss_license_types.join(', ')
      end
      row :values_screening
      row :business_models do
        span project.business_models.join(', ')
      end
      row :working_doc
      row :project_mgmt_url
      row :software_license_url
      row :attachments
      row :master_channel_list do
        span project.master_channel_list.join(', ')
      end
      row :project_created
      row :created_at
      row :updated_at
      row :flags do
        span project.flags.join("<br>").html_safe
      end
    end
  end

  controller do 

    def update
      resource.assign_attributes(permitted_params['project'])
      if resource.mission_aligned_changed?
        mission_aligned_changed = true
        mission_aligned_was = resource.mission_aligned_status(resource.mission_aligned_was)
      else
        mission_aligned_changed = false
      end

      if resource.save
        if mission_aligned_changed == true && resource.leads.any?
          resource.send_mission_aligned_changed_notification_email(mission_aligned_was)
          resource.send_mission_aligned_changed_slack_notifications(mission_aligned_was)
        end
        redirect_to admin_project_path(resource)
      else
        render :edit
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
      f.input :mission_aligned
    end

    f.inputs "Selections" do

      f.input :lead_ids, :label => "Project Leads", :as => :select, :collection => options_from_collection_for_select(User.all.pluck(:slack_username, :id), :second, :first, User.where(id: project.lead_ids).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :progcode_coordinator_ids, :label => "Progcode Coordinators", :as => :select, :collection => options_from_collection_for_select(User.all.pluck(:slack_username, :id), :second, :first, User.where(id: project.progcode_coordinator_ids).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :volunteers, :label => "Volunteers", :as => :select, :collection => options_from_collection_for_select(User.all.collect do |u|
        project_volunteering_ids = u.volunteering_ids  & project.volunteering_ids
        if project_volunteering_ids.any?
          states = Volunteering.where(id: project_volunteering_ids).map{|v| v.state}.join(', ')
          label = "#{u.label} (#{states})"
        else
          label = u.label
        end
        [label, u.id]
      end, :second, :first, User.where(id: project.volunteers.pluck(:id)).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :stacks, :input_html => { multiple: true, size: 60, class: 'select2' }
    end
    f.actions
  end
end
