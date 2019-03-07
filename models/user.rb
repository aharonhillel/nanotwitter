class User < ActiveRecord::Base
  has_many :tweets
  has_many :follows
  has_many :likes

  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :users, through: :follower_relationships, source: :user

  has_many :following_relationships, foreign_key: :user_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following


  validates :username, :email, presence: true, uniqueness: true
  validates :password_hash, presence: true

  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
