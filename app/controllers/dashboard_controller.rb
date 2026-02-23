class DashboardController < ApplicationController
  def index
    @reviews = ComplianceReview.all

    @total_reviews = @reviews.count
    @pending_count = @reviews.where(status: "Pending").count
    @flagged_count = @reviews.where(status: "Flagged").count

    # Calculate reviewer capacity (number of assigned pending/in-review tasks)
    @active_reviews = @reviews.where(status: [ "Pending", "In Review", "Flagged" ])
    @capacity = @active_reviews.group(:assigned_reviewer).count
  end
end
