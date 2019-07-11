class EmailNotifierMailer < ApplicationMailer
    default from: 'admin@progcode.org'

    layout "mailer"

    def new_volunteer_email
        mail(to:'sdklos@gmail.com', subject: 'We Received Your Application')
    end

    def existing_user_signed_up
        attachments.inline['logo-only.png'] = File.read("#{Rails.root}/app/assets/images/logo-only.png")
        @user = params[:user]
        mail(to: @user.email, subject: 'You Have Already Been Accepted')
    end

    def new_user_signed_up
        attachments.inline['logo-only.png'] = File.read("#{Rails.root}/app/assets/images/logo-only.png")
        @user = params[:user]
        mail(to: @user.email, subject: 'We Have Received Your Application')
    end

    def new_user_signed_up_again
        attachments.inline['logo-only.png'] = File.read("#{Rails.root}/app/assets/images/logo-only.png")
        @user = params[:user]
        mail(to: @user.email, subject: 'We Have Updated Your Application')
    end
end
