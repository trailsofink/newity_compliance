class ComplianceReviewsController < ApplicationController
  def index
    @reviews = ComplianceReview.active

    # Filters
    if params[:status] == "Overdue"
      @reviews = @reviews.overdue
    elsif params[:status].present?
      @reviews = @reviews.by_status(params[:status])
    end
    
    @reviews = @reviews.by_reviewer(params[:assigned_reviewer]) if params[:assigned_reviewer].present?

    # Priority sorting (Closest closing dates first to unblock loans)
    @reviews = @reviews.order(target_closing_date: :asc)

    @reviewers = ComplianceReview.distinct.pluck(:assigned_reviewer).compact
    @statuses = ComplianceReview::VALID_STATUSES + ["Overdue"]
  end

  def closed
    @reviews = ComplianceReview.closed.order(updated_at: :desc)
    @reviewers = ComplianceReview.distinct.pluck(:assigned_reviewer).compact
    @statuses = ComplianceReview::VALID_STATUSES
  end

  def edit
    @review = ComplianceReview.find(params[:id])
  end

  def update
    @review = ComplianceReview.find(params[:id])

    # Auto-stamp audit trail if status changes to a completed state
    is_closing = ActiveRecord::Type::Boolean.new.cast(compliance_review_params[:closed])
    if audit_trail_required?(compliance_review_params[:status]) || is_closing
      @review.reviewed_by ||= current_user&.name || "System"
      @review.review_date ||= Date.today
    end

    if @review.update(compliance_review_params)
      redirect_to compliance_reviews_path, notice: "Review updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def compliance_review_params
    params.require(:compliance_review).permit(:status, :priority, :assigned_reviewer, :closed)
  end

  def audit_trail_required?(new_status)
    [ "Approved", "Flagged", "Waived" ].include?(new_status)
  end
end
