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

  permit_params :name, :description, :website, :slack_channel, :active_contributors, :project_created, :mission_accomplished, :needs_pain_points_narrative, :org_structure, :project_mgmt_url, :summary_test, :repository, :software_license_url, :values_screening, :working_doc, :full_release_features, :attachments, :mission_aligned, :progcode_github_project_link,
  business_models: [],  legal_structures: [], oss_license_types: [], progcode_coordinator_ids: [], project_applications: [],  volunteer_ids: [], lead_ids: [], status: [], master_channel_list: [], volunteerings_attributes:[ :user_id], flags: [], tech_stack_ids: [], non_tech_stack_ids: [], needs_category_ids: []

  action_item :bulk_import do
    link_to "Bulk Import From Airtable", admin_projects_upload_csv_path
  end

  index do
    selectable_column
    column :name
    column :description do |project|
      span project.description.try(:truncate, 30), :title => project.description
    end
    column :leads do |project|
      project.leads.map(&:slack_username).to_sentence
    end
    column :progcode_coordinators do |project|
      project.progcode_coordinators.map(&:slack_username).to_sentence
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
    column :mission_aligned_status do |project|
      project.mission_aligned_status
    end
    column :flagged?
    column :updated_at
    actions
  end

  filter :name
  filter :description
  filter :slack_channel
  filter :by_mission_aligned_status_in, label: "Mission Aligned Status", as: :select, collection: %w[Confirmed Rejected Pending]
  filter :by_status_in, label: "Status", as: :select, collection: ProjectConstants::STATUSES, input_html: { multiple: true }
  filter :needs_categories, input_html: { multiple: true }
  filter :tech_stack, input_html: { multiple: true }
  filter :non_tech_stack, input_html: { multiple: true }
  filter :by_leads_in, label: "Lead", placeholder: "Search by name, email, or slack userid", as: :string
  filter :by_volunteers_in, label: "Volunteer",placeholder: "Search by name, email, or slack userid", as: :string
  filter :by_progcode_coordinators_in, label: "Progcode Coordinator", placeholder: "Search by name, email, or slack userid", as: :string
  filter :by_flagged_in, label: "Flagged?", as: :select, collection: %w[Yes No]
  filter :created_at
  filter :updated_at


  show do
    attributes_table do
      row :name
      row :status do
        span project.status.try(:join, ', ')
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
        span project.project_applications.try(:join, ', ')
      end
      row :active_contributors
      row :org_structure
      row :legal_structures do
        span project.legal_structures.try(:join, ', ')
      end
      row :oss_license_types do
        span project.oss_license_types.try(:join, ', ')
      end
      row :values_screening
      row :business_models do
        span project.business_models.try(:join, ', ')
      end
      row :working_doc
      row :project_mgmt_url
      row :software_license_url
      row :attachments
      row :master_channel_list do
        span project.master_channel_list.try(:join, ', ')
      end
      row :project_created
      row :created_at
      row :updated_at
      row :flags do
        span project.flags.try(:join, "<br>").try(:html_safe)
      end
    end
  end

  controller do 

    def create
      resource.assign_attributes(permitted_params['project'])

      volunteerings = resource.volunteerings.pluck(:id)

      if volunteerings.any?
        volunteerings.each{|v| Volunteering.find(v).set_active!(ENV['AASM_OVERRIDE'])}
      end

      resource.flags.reject!(&:empty?)

      resource.save(:validate => false)

      redirect_to admin_project_path(resource)
    end

    def update
      old_volunteering_ids = resource.volunteering_ids.clone
      resource.assign_attributes(permitted_params['project'])
      if resource.mission_aligned_changed?
        mission_aligned_changed = true
        mission_aligned_was = resource.mission_aligned_status(resource.mission_aligned_was)
      else
        mission_aligned_changed = false
      end

      new_volunteerings = resource.volunteerings.pluck(:id) - old_volunteering_ids

      if new_volunteerings.any?
        new_volunteerings.each{|v| Volunteering.find(v).set_active!(ENV['AASM_OVERRIDE'])}
      end

      resource.flags.reject!(&:empty?)

      resource.save(:validate => false)
        if mission_aligned_changed == true && resource.leads.any?
          resource.send_mission_aligned_changed_notification_email(mission_aligned_was)
          resource.send_mission_aligned_changed_slack_notifications(mission_aligned_was)
        end
      redirect_to admin_project_path(resource)
    end

    def upload_csv

    end

    def import_data
      @projects = []
      @attributes = Project.column_names
      CSV.foreach(params[:file].path, headers: true) do |row|
        if row[0].present?
          airtable_id = row["Record ID"]
          proj = Project.find_or_initialize_by(airtable_id: airtable_id)
          airtable_project = AirtableProject.find(airtable_id)
          proj.sync_with_airtable(airtable_project)
          @projects << proj
        end
      end

      render 'import_success'

    end

  end

  form do |f|
    f.inputs "Basic Info" do
      f.input :name
      f.input :status, as: :select, collection: ProjectConstants::STATUSES, input_html: { multiple: true }
      f.input :description
      f.input :website
      f.input :slack_channel, :as => :datalist, :collection => SlackHelpers.get_slack_channels.pluck(:name)
      f.input :mission_aligned, :as => :select
      f.input :legal_structures, as: :select, :collection => Project::LEGAL_STRUCTURE, :input_html => { :multiple => true }, :include_blank  => false, :include_hidden => false
    end

    f.inputs "Participants" do
      f.input :lead_ids, :label => "Project Leads", :as => :select, :collection => options_from_collection_for_select(User.all.pluck(:slack_username, :id), :second, :first, User.where(id: project.lead_ids).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :progcode_coordinator_ids, :label => "Progcode Coordinators", :as => :select, :collection => options_from_collection_for_select(User.all.pluck(:slack_username, :id), :second, :first, User.where(id: project.progcode_coordinator_ids).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :volunteers, :label => "Volunteers: you can add or remove volunteers here.<br>Click #{link_to 'here', admin_volunteerings_path} to change the status of volunteers".html_safe, :as => :select, :collection => options_from_collection_for_select(collection_select_for_project_volunteers(project), :second, :first, User.where(id: project.volunteers.pluck(:id)).pluck(:id)), :input_html => { multiple: true, size: 60, class: 'select2' }
      project.volunteers.each do |v|
        'hi'
      end
    end
    f.inputs "Stack" do
      f.input :tech_stack, :collection => Skill.tech_skills, :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :non_tech_stack, :collection => Skill.non_tech_skills, :input_html => { multiple: true, size: 60, class: 'select2' }

      f.input :needs_categories, :input_html => { multiple: true, size: 60, class: 'select2' }
    end

    f.inputs "Additonal" do
      f.input :mission_accomplished
      f.input :needs_pain_points_narrative
      f.input :org_structure, as: :select, :collection => Project::ORG_STRUCTURE, :include_blank => true
      f.input :active_contributors
      f.input :full_release_features
      f.input :project_mgmt_url
      f.input :repository
      f.input :software_license_url
      f.input :values_screening, as: :select, :collection => Project::VALUES_SCREENING, :include_blank => true
      f.input :working_doc
      f.input :business_models, as: :select, :collection => Project::BUSINESS_MODEL, :input_html => { :multiple => true }, :include_blank => true, :include_hidden => false
      f.input :oss_license_types, as: :select, :collection => Project::OSS_LICENSE_TYPE, :input_html => { :multiple => true }, :include_blank  => true, :include_hidden => false
      f.input :project_applications, as: :select, :collection => Project::PROJECT_APPLICATIONS, :input_html => { :multiple => true, class: 'select2' }, :include_blank => true, :include_hidden => false
      f.input :attachments
      f.input :progcode_github_project_link
      f.input :master_channel_list, :as => :select, :collection => SlackHelpers.get_slack_channels.pluck(:name), :input_html => { :multiple => true, size: 60, class: 'select2' }, :include_blank => true, :include_hidden => false
    end

    f.inputs "Flags" do
      project.flags.each do |flag|
        f.input :flags, :label => false, :input_html => {value: flag, name: 'project[flags][]'}
      end
      f.input :flags, :label => false, :input_html => {value: '', placeholder: 'Flag an issue with this project', name: 'project[flags][]'}
    end
    f.actions
  end
end
