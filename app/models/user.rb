class User < ApplicationRecord
  has_secure_password
  has_one_attached :profile_image
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  has_many :comments, dependent: :nullify
end
