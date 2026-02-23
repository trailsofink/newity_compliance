require "test_helper"

class ApplicationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@newity.com", password: "password")
    post login_path, params: { email: @user.email, password: @user.password }

    @application = applications(:one)
    @review = ComplianceReview.create!(
      application: @application,
      item_name: "Verification",
      status: "Pending"
    )
  end

  test "should get index" do
    get applications_url
    assert_response :success
    assert_select "h1", text: "Applications"
  end

  test "should get show" do
    get application_url(@application)
    assert_response :success
    assert_select "h1", text: "Application: APP-1"
  end

  test "should sort applications by application_identifier asc" do
    get applications_url, params: { sort: "app_id_asc" }
    assert_response :success

    # We expect APP-1 to come before APP-2
    assert_select "details", count: 2
    assert_select "details:nth-of-type(1) summary", text: /APP-1/
    assert_select "details:nth-of-type(2) summary", text: /APP-2/
  end

  test "should sort applications by application_identifier desc" do
    get applications_url, params: { sort: "app_id_desc" }
    assert_response :success

    # We expect APP-2 to come before APP-1
    assert_select "details", count: 2
    assert_select "details:nth-of-type(1) summary", text: /APP-2/
    assert_select "details:nth-of-type(2) summary", text: /APP-1/
  end

  test "should sort applications by target_closing_date asc" do
    # APP-1 is 2026-03-01, APP-2 is 2026-03-15 (from fixtures)
    get applications_url, params: { sort: "target_date_asc" }
    assert_response :success

    assert_select "details:nth-of-type(1) summary", text: /APP-1/
    assert_select "details:nth-of-type(2) summary", text: /APP-2/
  end

  test "should sort applications by target_closing_date desc" do
    get applications_url, params: { sort: "target_date_desc" }
    assert_response :success

    assert_select "details:nth-of-type(1) summary", text: /APP-2/
    assert_select "details:nth-of-type(2) summary", text: /APP-1/
  end
end
