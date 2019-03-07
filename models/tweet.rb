class Tweet < ActiveRecord::Base
  belongs_to :user
    has_many :likes
    has_many :mentions
    has_many :hashtags
    has_many :comments

    validates :user_id, :content, presence: true
end
