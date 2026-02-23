class Application < ApplicationRecord
  has_many :compliance_reviews, dependent: :destroy
end
