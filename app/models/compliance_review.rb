class ComplianceReview < ApplicationRecord
  has_paper_trail
  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :comments, reject_if: proc { |attributes| attributes["body"].blank? }

  VALID_STATUSES = [ "Pending", "In Review", "Approved", "Flagged", "Waived" ].freeze

  validates :item_name, :status, presence: true
  validates :status, inclusion: { in: VALID_STATUSES }

  belongs_to :application
  delegate :borrower_name, :loan_amount, :target_closing_date, :application_identifier, to: :application

  # Audit trail validations: If it's finalized, we MUST know who did it and when.
  validates :reviewed_by, :review_date, presence: true, if: :completed?

  # Flagged items require notes for remediation, Waived require a reason.
  validate :must_have_comment_for_flagged_or_waived

  # Scopes for querying the queue
  scope :blocking_closings, -> {
    joins(:application)
    .where(status: [ "Pending", "In Review", "Flagged" ])
    .order("applications.target_closing_date ASC")
  }

  scope :by_reviewer, ->(reviewer) { where(assigned_reviewer: reviewer) if reviewer.present? }
  scope :by_status, ->(status) { where(status: status) if status.present? }

  scope :overdue, -> {
    joins(:application)
    .where(status: [ "Pending", "In Review", "Flagged" ])
    .where("applications.target_closing_date < ?", Date.today)
  }

  def completed?
    [ "Approved", "Flagged", "Waived" ].include?(status)
  end

  def blocking?
    [ "Pending", "Flagged" ].include?(status) && target_closing_date.present? && target_closing_date <= 2.weeks.from_now
  end

  private

  def must_have_comment_for_flagged_or_waived
    if [ "Flagged", "Waived" ].include?(status) && comments.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "You must provide a comment or reasoning for a Flagged or Waived review.")
    end
  end
end
