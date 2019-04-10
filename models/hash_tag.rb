class HashTag < ActiveRecord::Base
  has_many :hash_tag_tweets, dependent: :nullify
  has_many :tweets, through: :hash_tag_tweets

  validates :description, uniqueness: true, presence: true, length: {maximum: 20}
end