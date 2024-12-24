class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  after_create :assign_default_role
  rolify

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :likes, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :phone_number, presence: true, format: { with: /\A\d{10,15}\z/, message: "must be a valid phone number" }

  def assign_default_role
    self.add_role(:user) if self.roles.blank?
  end
  # def assign_default_role
  #   self.role ||= 'default'
  #   save
  # end

end
