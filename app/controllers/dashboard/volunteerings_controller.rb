class Dashboard::VolunteeringsController < Dashboard::BaseController
    inherit_resources

    def index
      @volunteerings = current_user.relevant_volunteerings.select {|v| v.valid?}
    end

    def new
      @volunteering = Volunteering.new(:project_id => params[:project_id], :user_id => current_user.id)

      @project = @volunteering.project
    end

    def create
      @volunteering = Volunteering.create(:project_id => volunteering_params[:project_id], :user_id => current_user.id)

      if volunteering_params[:event] == 'apply'
        @volunteering.apply!(current_user)
      end

      redirect_to dashboard_volunteerings_path
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
      params.require(:volunteering).permit(:user_id, :project_id, :event)
    end

end