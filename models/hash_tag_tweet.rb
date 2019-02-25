class HashTagTweet < ActiveRecord::Base
  belongs_to :hash_tag_tweet
  belongs_to :tweet
end