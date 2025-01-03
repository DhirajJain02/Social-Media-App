class User < ApplicationRecord
  rolify
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts, dependent: :destroy
  after_create :assign_default_role
  after_create :send_welcome_email


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :likes, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  # validate :must_select_at_least_one_role
  validates :phone_number, presence: true, format: { with: /\A\d{10,15}\z/, message: "must be a valid phone number" }, uniqueness: true
  # has_and_belongs_to_many :roles

  # Send welcome email after user creation
  def send_welcome_email
    LoginMailer.login_notification(self).deliver_later
  end

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
  def active_for_authentication?
    super && active? # If the user is active, they can log in
  end

  def must_select_at_least_one_role
    errors.add(:role_ids, "must have at least one role selected") if role_ids.blank? || role_ids.empty?
  end

  def inactive_message
    "Your account has been deactivated. Please contact support." # Custom message when inactive
  end

end
