require "test_helper"

class ComplianceReviewTest < ActiveSupport::TestCase
  def setup
    @review = ComplianceReview.new(
      application_id: "COMP-2026-2001",
      borrower_name: "Carlos Martin",
      target_closing_date: Date.today + 5.days,
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

  test "should require notes when Flagged" do
    @review.status = "Flagged"
    assert_not @review.valid?, "Should be invalid without notes when flagged"

    @review.notes = "Missing signature"
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
    ComplianceReview.create!(application_id: "1", borrower_name: "A", item_name: "Item", status: "Approved", target_closing_date: Date.today + 1.day, reviewed_by: "Me", review_date: Date.today)
    r2 = ComplianceReview.create!(application_id: "2", borrower_name: "B", item_name: "Item", status: "Pending", target_closing_date: Date.today + 2.days)
    r3 = ComplianceReview.create!(application_id: "3", borrower_name: "C", item_name: "Item", status: "Flagged", target_closing_date: Date.today + 1.day, notes: "Fix", reviewed_by: "Me", review_date: Date.today)

    blocking = ComplianceReview.blocking_closings

    # In a full test DB there might be other seeded items, but isolated test DB might only have these.
    # To be safe, we check relative order or explicitly query by IDs.
    our_blocking = blocking.where(id: [ r2.id, r3.id ])
    assert_equal 2, our_blocking.count
    assert_equal "3", our_blocking.first.application_id # Closest target date first
    assert_equal "2", our_blocking.last.application_id
  end
end
