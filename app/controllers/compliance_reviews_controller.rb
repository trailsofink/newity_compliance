class ComplianceReviewsController < ApplicationController
  def index
    @reviews = ComplianceReview.all
    
    # Filters
    @reviews = @reviews.by_status(params[:status]) if params[:status].present?
    @reviews = @reviews.by_reviewer(params[:assigned_reviewer]) if params[:assigned_reviewer].present?
    
    # Priority sorting (Closest closing dates first to unblock loans)
    @reviews = @reviews.order(target_closing_date: :asc)
    
    @reviewers = ComplianceReview.distinct.pluck(:assigned_reviewer).compact
    @statuses = ComplianceReview::VALID_STATUSES
  end

  def edit
    @review = ComplianceReview.find(params[:id])
  end

  def update
    @review = ComplianceReview.find(params[:id])
    
    # Auto-stamp audit trail if status changes to a completed state
    if audit_trail_required?(review_params[:status])
      @review.reviewed_by ||= current_user&.name || "System"
      @review.review_date ||= Date.today
    end

    if @review.update(review_params)
      redirect_to compliance_reviews_path, notice: 'Review updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def review_params
    params.require(:compliance_review).permit(:status, :assigned_reviewer, :notes, :priority)
  end

  def audit_trail_required?(new_status)
    ['Approved', 'Flagged', 'Waived'].include?(new_status)
  end
end
