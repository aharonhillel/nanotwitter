class User < ActiveRecord::Base
    has_many :tweets
    has_many :follows
    has_many :likes
    validates :email, presence: true, uniqueness: true
end
