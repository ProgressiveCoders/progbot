module ActiveAdmin::ViewsHelper

  def collection_select_for_project_volunteers(project)
    proj_volunteer_ids = project.volunteers.pluck(:id)
    project_id = project.id
    User.all.collect do |u|
      if proj_volunteer_ids.include?(u.id)
        state = Volunteering.where(:user_id => u.id).where(:project_id => project.id).take.state
        label = link_to "#{u.admin_label} (#{state})", edit_admin_volunteering_path()
      else
        label = "#{u.label}"
      end
      [label, u.id]
    end
  end
end