class HashTag < ActiveRecord::Base
  has_many :hash_tag_tweets
end