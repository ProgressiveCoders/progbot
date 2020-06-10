class EmailNotifierMailer < ApplicationMailer
    default from: 'admin@progcode.org'

    layout 'email_notifier'

    before_action { @user, @project, @volunteering = params[:user], params[:project], params[:volunteering] }
    before_action :set_attachment_source

    def new_user_admin_notification
      mail(to: check_testing_status, subject: 'New User Signup')
    end

    def new_project_admin_notification
        mail(to: check_testing_status, subject: 'New Project')
    end

    def new_project_confirmation
        mail(to: check_testing_status, subject: 'New Project')
    end

    def project_mission_aligned_changed
        @mission_aligned_was = params[:mission_aligned_was]
        mail(to: check_testing_status(@project.leads.pluck(:email)), subject: "Your Project's Mission Aligned Status has been Updated")
    end

    def existing_user_signed_up
      mail(to: @user.email, subject: 'You Have Already Been Accepted')
    end

    def new_user_signed_up
      mail(to: @user.email, subject: 'We Have Received Your Application')
    end

    def new_user_signed_up_again
      mail(to: @user.email, subject: 'We Have Updated Your Application')
    end

    def new_volunteer_email
      mail(to: params[:emails], subject: 'You Have a New Volunteer!')
    end

    def new_recruit_email
      mail(to: @user.email, subject: "Invitation to join #{@project.name}")

    end

    private

    def check_testing_status(prod_target = 'admin@progcode.org')
      Rails.env.production? ? prod_target : 'sdklos@gmail.com'
    end

    def set_attachment_source
      attachments.inline['logo-only.png'] = File.read("#{Rails.root}/app/assets/images/logo-only.png")
    end
end
