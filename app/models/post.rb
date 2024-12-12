class Post < ApplicationRecord
  # Validations for title and description
  validates :title, presence: true
  validates :description, presence: true
  has_many :comments,->{ order(created_at: :desc) }, dependent: :destroy
  has_many :likes, dependent: :destroy
  # This will allow us to count likes easily
  has_many :likers, through: :likes
end
