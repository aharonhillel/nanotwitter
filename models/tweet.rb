class User < ActiveRecord::Base
  belongs_to :user
    has_many :likes
    has_many :mentions
    has_many :hashtags
    has_many :comments
end
