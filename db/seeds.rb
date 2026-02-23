require 'csv'

# Create default users
[ 'Diana Okafor', 'Sarah Lindgren', 'Marcus Chen' ].each do |name|
  email = name.downcase.gsub(' ', '.') + '@newity.com'
  User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = 'password123'
    u.password_confirmation = 'password123'
  end
end
puts "Created #{User.count} users."

# Import CSV
csv_text = File.read(Rails.root.join('../sample_data_c_compliance_queue.csv'))
csv = CSV.parse(csv_text, headers: true)

csv.each do |row|
  app = Application.find_or_create_by!(application_identifier: row['application_id']) do |a|
    a.borrower_name = row['borrower_name']
    a.loan_amount = row['loan_amount']
    a.target_closing_date = row['target_closing_date']
  end

  review = ComplianceReview.new(
    application: app,
    item_name: row['compliance_item'],
    status: row['status'],
    assigned_reviewer: row['assigned_reviewer'],
    assigned_date: row['assigned_date'],
    review_date: row['review_date'],
    reviewed_by: row['reviewed_by'],
    priority: row['priority']
  )

  if row['notes'].present?
    user = User.find_by(name: row['reviewed_by'].presence || row['assigned_reviewer'].presence) || User.first
    review.comments.build(body: row['notes'], user: user)
  end

  review.save!
end
puts "Seeded #{ComplianceReview.count} records and #{Comment.count} comments."
