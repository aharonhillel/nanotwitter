class Like < ActiveRecord::Base
  belongs_to :tweets
  belongs_to :users

  validates :user_id, uniqueness: { scope: :tweet_id }
end
