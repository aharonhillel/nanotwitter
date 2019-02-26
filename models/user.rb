class User < ActiveRecord::Base
  has_many :tweets
  has_many :follows
  has_many :likes
  validates :username, :email, presence: true, uniqueness: true
  validates :password, presence: true

  include BCrypt

  def password
    @password ||= Password.new(password)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
