class User < ActiveRecord::Base
  has_many :tweets
  has_many :follows
  has_many :likes
  validates :username, :email, presence: true, uniqueness: true
  validates :password, presence: true
end
