class Tweet < ActiveRecord::Base
  belongs_to :user
    has_many :likes
    has_many :mentions
    has_many :comments
    has_many :hash_tag_tweets
    has_many :hash_tags, through: :hash_tag_tweets

    validates :user_id, :content, presence: true
end
