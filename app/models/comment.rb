class Comment < ApplicationRecord
  belongs_to :compliance_review
  belongs_to :user

  validates :body, presence: true
end
