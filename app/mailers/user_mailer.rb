class UserMailer < ApplicationMailer

    def confirmation_email
        @user = params[:user]
        mail(to: @user.email, subject: 'We Received your ProgCode Registration')
    end
end
