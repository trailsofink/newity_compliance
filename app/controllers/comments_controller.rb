class CommentsController < ApplicationController
  def create
    @review = ComplianceReview.find(params[:compliance_review_id])
    @comment = @review.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to edit_compliance_review_path(@review), notice: "Comment added successfully."
    else
      redirect_to edit_compliance_review_path(@review), alert: "Failed to add comment. Comment cannot be blank."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
