class UploadNotificationJob < ApplicationJob
  queue_as :default

  def perform(admin_email, uploaded_users)
    AdminMailer.upload_status_email(admin_email, uploaded_users).deliver_now
  end
end
