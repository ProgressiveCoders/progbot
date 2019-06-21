class EmailNotifierMailer < ApplicationMailer
    default from: 'admin@progcode.org'

    layout "mailer"

    def new_volunteer_email
        mail(to:'sdklos@gmail.com', subject: 'Welcome to My Awesome Site')
    end
end
