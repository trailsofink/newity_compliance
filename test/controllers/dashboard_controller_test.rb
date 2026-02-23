require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@newity.com", password: "password")
    post login_path, params: { email: @user.email, password: @user.password }
  end

  test "should get index" do
    get root_url
    assert_response :success
  end
end
