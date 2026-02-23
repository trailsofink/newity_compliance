class ApplicationsController < ApplicationController
  def index
    @applications = Application.includes(:compliance_reviews).all

    if params[:sort].present?
      case params[:sort]
      when "app_id_asc"
        @applications = @applications.order(application_identifier: :asc)
      when "app_id_desc"
        @applications = @applications.order(application_identifier: :desc)
      when "target_date_asc"
        @applications = @applications.order(target_closing_date: :asc)
      when "target_date_desc"
        @applications = @applications.order(target_closing_date: :desc)
      end
    end
  end

  def show
    @application = Application.includes(:compliance_reviews).find(params[:id])
  end

  def new
    @application = Application.new
    @application.compliance_reviews.build
  end

  def create
    @application = Application.new(application_params)
    if @application.save
      redirect_to @application, notice: "Application was successfully created."
    else
      @application.compliance_reviews.build if @application.compliance_reviews.empty?
      render :new, status: :unprocessable_entity
    end
  end

  private

  def application_params
    params.require(:application).permit(
      :application_identifier,
      :borrower_name,
      :loan_amount,
      :target_closing_date,
      compliance_reviews_attributes: [ :id, :item_name, :status, :assigned_reviewer, :priority, :_destroy ]
    )
  end
end
