class LoginMailer < ApplicationMailer
  default from: "dhiraj.lodha@jarvis.consulting" # Use the verified sender email

  def test_email(email)
    mail(
      to: email,
      subject: "Test Email from Rails App",
      body: "Hello! This is a test email to check if SendGrid integration works."
    )
  end

  def login_notification(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to Our Application") do |format|
      format.text { render plain: "Hello #{@user.first_name},\n\nThank you for signing up!" }
      format.html { render html: "<h1>Hello #{@user.first_name},</h1><p>Thank you for signing up!</p>".html_safe }
    end
  end

end
