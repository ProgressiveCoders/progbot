class Dashboard::VolunteeringsController < Dashboard::BaseController
    inherit_resources
    include ProjectsHelper

    before_action :get_contributor_slack_information, only: :edit

    def index
      @volunteerings = current_user.relevant_volunteerings.select {|v| v.valid?}
    end

    def new_signup
      @volunteering = Volunteering.new(:project_id => params[:project_id], :user_id => current_user.id)

      @project = @volunteering.project
    end

    def new_recruit
      @volunteering = Volunteering.new
      @available_projects = current_user.projects.where(:mission_aligned => true)
      @user = User.find_by(:secure_token => params[:temporary_token])
      @user.secure_token = User.generate_unique_secure_token
      @user.save(:validate => false)
      @token = @user.secure_token
      @skill_names = @user.skill_names_for_display
    end

    def create
      @project = Project.find(volunteering_params[:project_id])
      if volunteering_params[:event] == 'apply'
        @volunteering = Volunteering.create(:project_id => @project.id, :user_id => current_user.id)
        @volunteering.apply!(current_user)
        redirect_to dashboard_volunteerings_path
      elsif volunteering_params[:event] == 'recruit'
        @user = User.find_by(:secure_token => volunteering_params[:secure_token])
        if @user.blank?
          render plain: "The form information you submitted has expired. Please try again or contact an admin for help"
        else
          @volunteering = Volunteering.create(:project_id => @project.id, :user_id => @user.id)
          @volunteering.recruit!(current_user)
          @user.secure_token = User.generate_unique_secure_token
          @user.save(:validate => false)
          redirect_to dashboard_projects_path
        end
      end
    end

    def edit
      @user = resource.user
      @project = resource.project

      if @project.leads.include?(current_user) || @user == current_user
        render :edit
      else
        redirect_to dashboard_volunteerings_path
      end
    end

    def update
      case volunteering_params[:event]
      when 'apply'
        resource.apply!(current_user)
      when 'recruit'
        resource.recruit!(current_user)
      when 'withdraw'
        resource.withdraw!(current_user)
      when 'confirm'
        resource.confirm!(current_user)
      when 'leave'
        resource.leave!(current_user)
      when 'remove'
        resource.remove!(current_user)
      end

      redirect_to edit_dashboard_volunteering_path(resource)

    end

    private

    def volunteering_params
      params.require(:volunteering).permit(:user_id, :project_id, :event, :secure_token)
    end

    def get_contributor_slack_information
      contributor_attributes(resource.project).each do |key, values|
        if values.present?
          values.each do |v|
            v.get_slack_details
            v.safe(:validate => false)
          end
        end
      end
    end

end