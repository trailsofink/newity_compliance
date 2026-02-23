class CreateComplianceReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :compliance_reviews do |t|
      t.string :application_id
      t.string :borrower_name
      t.decimal :loan_amount
      t.date :target_closing_date
      t.string :item_name
      t.string :status
      t.string :assigned_reviewer
      t.date :assigned_date
      t.date :review_date
      t.string :reviewed_by
      t.text :notes
      t.string :priority

      t.timestamps
    end
  end
end
