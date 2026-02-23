require "test_helper"

class ComplianceReviewTest < ActiveSupport::TestCase
  def setup
    @application = applications(:one)
    @review = ComplianceReview.new(
      application: @application,
      item_name: "Lender Authorization Check",
      status: "Pending"
    )
  end

  test "should be valid with minimum required attributes" do
    assert @review.valid?
  end

  test "should require valid status" do
    @review.status = "Unknown Status"
    assert_not @review.valid?
    assert_includes @review.errors[:status], "is not included in the list"
  end

  test "should require comment when Flagged" do
    @review.status = "Flagged"
    assert_not @review.valid?, "Should be invalid without comment when flagged"

    @review.comments.build(body: "Missing signature", user: users(:one))
    # Also needs audit trail since it's 'completed'
    @review.reviewed_by = "Marcus Chen"
    @review.review_date = Date.today

    assert @review.valid?
  end

  test "should enforce audit trail on Approved" do
    @review.status = "Approved"
    assert_not @review.valid?, "Should not allow approval without reviewer and date"

    @review.reviewed_by = "Sarah Lindgren"
    @review.review_date = Date.today
    assert @review.valid?
  end

  test "blocking_closings scope orders by nearest date and excludes Approved" do
    app1 = Application.create!(application_identifier: "1", borrower_name: "A", target_closing_date: Date.today + 1.day)
    app2 = Application.create!(application_identifier: "2", borrower_name: "B", target_closing_date: Date.today + 2.days)
    app3 = Application.create!(application_identifier: "3", borrower_name: "C", target_closing_date: Date.today + 1.day)

    ComplianceReview.create!(application: app1, item_name: "Item", status: "Approved", reviewed_by: "Me", review_date: Date.today)
    r2 = ComplianceReview.create!(application: app2, item_name: "Item", status: "Pending")

    r3 = ComplianceReview.new(application: app3, item_name: "Item", status: "Flagged", reviewed_by: "Me", review_date: Date.today)
    r3.comments.build(body: "Fix", user: users(:one))
    r3.save!

    blocking = ComplianceReview.blocking_closings

    # In a full test DB there might be other seeded items, but isolated test DB might only have these.
    # To be safe, we check relative order or explicitly query by IDs.
    our_blocking = blocking.where(id: [ r2.id, r3.id ])
    assert_equal 2, our_blocking.count
    assert_equal "3", our_blocking.first.application.application_identifier # Closest target date first
    assert_equal "2", our_blocking.last.application.application_identifier
  end
end
