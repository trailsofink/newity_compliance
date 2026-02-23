class MigrateComplianceReviewToApplication < ActiveRecord::Migration[8.0]
  class MigrationApplication < ActiveRecord::Base
    self.table_name = 'applications'
  end

  class MigrationComplianceReview < ActiveRecord::Base
    self.table_name = 'compliance_reviews'
  end

  def up
    rename_column :compliance_reviews, :application_id, :legacy_application_id
    add_reference :compliance_reviews, :application, foreign_key: true

    MigrationComplianceReview.reset_column_information
    MigrationApplication.reset_column_information

    MigrationComplianceReview.find_each do |cr|
      app = MigrationApplication.find_or_create_by!(application_identifier: cr.legacy_application_id) do |a|
        a.borrower_name = cr.borrower_name
        a.loan_amount = cr.loan_amount
        a.target_closing_date = cr.target_closing_date
      end
      cr.update_columns(application_id: app.id)
    end

    remove_column :compliance_reviews, :legacy_application_id
    remove_column :compliance_reviews, :borrower_name
    remove_column :compliance_reviews, :loan_amount
    remove_column :compliance_reviews, :target_closing_date
  end

  def down
    add_column :compliance_reviews, :legacy_application_id, :string
    add_column :compliance_reviews, :borrower_name, :string
    add_column :compliance_reviews, :loan_amount, :decimal
    add_column :compliance_reviews, :target_closing_date, :date

    MigrationComplianceReview.reset_column_information
    MigrationApplication.reset_column_information

    MigrationComplianceReview.find_each do |cr|
      app = MigrationApplication.find_by(id: cr.application_id)
      if app
        cr.update_columns(
          legacy_application_id: app.application_identifier,
          borrower_name: app.borrower_name,
          loan_amount: app.loan_amount,
          target_closing_date: app.target_closing_date
        )
      end
    end

    remove_reference :compliance_reviews, :application, foreign_key: true
    rename_column :compliance_reviews, :legacy_application_id, :application_id
  end
end
