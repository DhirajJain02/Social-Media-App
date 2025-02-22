class Post < ApplicationRecord
  belongs_to :user

  # Validations for title and description
  validates :title, presence: true
  validates :description, presence: true
  has_many :comments, ->{ order(created_at: :desc) }, dependent: :destroy
  has_many :likes, dependent: :destroy
  # Define constants for visibility
  VISIBILITY_OPTIONS = ["private", "public"]

  # Validation for visibility
  validates :visibility, inclusion: { in: VISIBILITY_OPTIONS }
  # enum visibility: { public: 'public', private: 'private' } # Enum for visibility options

  # def liked_by?(user)
  #   likes.exists?(user_id: user.id)
  # end
  def comment_contents
    comments.pluck(:content)
  end
end
