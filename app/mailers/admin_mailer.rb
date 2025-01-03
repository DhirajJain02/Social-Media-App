class AdminMailer < ApplicationMailer
  default from: "dhiraj.lodha@jarvis.consulting"

  def upload_status_email(admin_email, user_statuses)
    @user_statuses = user_statuses
    mail(to: admin_email, subject: "User Upload Status")

  end
end
