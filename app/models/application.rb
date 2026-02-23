class Application < ApplicationRecord
  has_many :compliance_reviews, dependent: :destroy
  accepts_nested_attributes_for :compliance_reviews, allow_destroy: true, reject_if: proc { |attributes| attributes["item_name"].blank? }

  validates :application_identifier, :borrower_name, presence: true
end
