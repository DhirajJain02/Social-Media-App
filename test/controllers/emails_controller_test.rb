require "test_helper"

class EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get test_email" do
    get emails_test_email_url
    assert_response :success
  end
end
