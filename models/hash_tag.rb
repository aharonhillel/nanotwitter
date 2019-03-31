class HashTag < ActiveRecord::Base
  has_many :hash_tag_tweets
  has_many :tweets, through: :hash_tag_tweets
end