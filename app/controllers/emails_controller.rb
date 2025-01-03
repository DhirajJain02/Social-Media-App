class EmailsController < ApplicationController
  def test_email
    if request.post?
      email = params[:email]
      if email.present?
        LoginMailer.test_email(email).deliver_now
        flash[:notice] = "Test email sent to #{email}"
      else
        flash[:alert] = "Please enter a valid email address."
      end
    end
  end
end