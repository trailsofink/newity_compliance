require "test_helper"

class ComplianceReviewsEditTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Tester", email: "test@example.com", password: "password")
    @review = compliance_reviews(:one)
    
    # Login manually if sessions#create is available
    post login_path, params: { email: @user.email, password: 'password' } 
  end

  test "can post a comment without redirecting away from edit page" do
    assert_difference('Comment.count', 1) do
      post compliance_review_comments_path(@review), params: {
        comment: { body: "This is a test comment" }
      }
    end
    
    assert_redirected_to edit_compliance_review_path(@review)
    follow_redirect!
    assert_match "This is a test comment", response.body
  end

  test "can save review changes without affecting comments" do
    patch compliance_review_path(@review), params: {
      compliance_review: { status: "Approved", priority: "High" }
    }
    
    assert_redirected_to compliance_reviews_path
    @review.reload
    assert_equal "Approved", @review.status
    assert_equal "High", @review.priority
  end
end
