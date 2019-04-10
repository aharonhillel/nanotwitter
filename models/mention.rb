class Mention < ActiveRecord::Base
  belongs_to :mentioned_in_tweet, foreign_key: 'tweet_id', class_name: 'Tweet'
  belongs_to :mentioned_user, foreign_key: 'user_id', class_name: 'User'

  validates :tweet_id, :user_id, presence: true

  # Control for valid username in the frontend
  # validate :cannot_mention_nonexistent_user
  #
  # def cannot_mention_nonexistent_user
  #   if User.find_by_id(:mentioned_user).nil?
  #     errors.add("No such user")
  #   end
  # end
end
