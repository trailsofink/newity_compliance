class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.string :application_identifier
      t.string :borrower_name
      t.decimal :loan_amount
      t.date :target_closing_date

      t.timestamps
    end
    add_index :applications, :application_identifier, unique: true
  end
end
