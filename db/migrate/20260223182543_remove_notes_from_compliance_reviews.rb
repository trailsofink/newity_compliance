class RemoveNotesFromComplianceReviews < ActiveRecord::Migration[8.0]
  def change
    remove_column :compliance_reviews, :notes, :text
  end
end
