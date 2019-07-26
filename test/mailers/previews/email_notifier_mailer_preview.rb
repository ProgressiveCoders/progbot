# Preview all emails at http://localhost:3000/rails/mailers/email_notifier_mailer
class EmailNotifierMailerPreview < ActionMailer::Preview


def new_user_admin_notification
    EmailNotifierMailer.with(user: User.first).new_user_admin_notification
end

def new_project_admin_notification

end

def new_project_confirmation

end

def existing_user_signed_up
    
end

def new_user_signed_up

end

def new_user_signed_up_again
    EmailNotifierMailer.with(user: User.first).new_user_signed_up_again
end

end
