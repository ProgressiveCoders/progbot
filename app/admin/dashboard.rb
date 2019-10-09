ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

     columns do
       column do
         panel "Recently Updated Projects" do
           ul do
             Project.order(:updated_at).limit(5).map do |project|
               li link_to(project.name, admin_project_path(project))
             end
           end
         end
       end

       column do
         panel "Recently Updated Users" do
          ul do
            User.order(:updated_at).limit(5).map do |user|
              li link_to(user.slack_username, admin_user_path(user))
            end
          end
        end
      end
    end
  end
end
