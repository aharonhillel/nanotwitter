class Like < ActiveRecord::Base
  belongs_to :tweet, counter_cache: :total_likes
  belongs_to :user

  validates :user_id, uniqueness: { scope: :tweet_id }
end
