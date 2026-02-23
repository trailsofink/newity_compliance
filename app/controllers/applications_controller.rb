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
end
