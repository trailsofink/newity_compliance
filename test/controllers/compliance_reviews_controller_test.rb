require "test_helper"

class ComplianceReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Test User", email: "test@newity.com", password: "password")
    
    @review = ComplianceReview.create!(
      application_id: "COMP-TEST",
      borrower_name: "Wei King",
      item_name: "Credit Memo Review",
      status: "Pending",
      target_closing_date: Date.today + 10.days
    )

    # Simple log in step since ApplicationController requires authenticated user
    post login_path, params: { email: @user.email, password: @user.password }
  end

  test "should get index" do
    get compliance_reviews_url
    assert_response :success
    assert_select "td", text: "COMP-TEST"
  end

  test "should filter by status" do
    get compliance_reviews_url, params: { status: "Approved" }
    assert_response :success
    # Should not show the pending item
    assert_select "td", text: "COMP-TEST", count: 0
  end

  test "should update review and auto-stamp audit trail" do
    patch compliance_review_url(@review), params: { 
      compliance_review: { status: "Approved" } 
    }
    
    @review.reload
    assert_redirected_to compliance_reviews_url
    assert_equal "Approved", @review.status
    assert_not_nil @review.review_date
    assert_not_nil @review.reviewed_by
  end
end
