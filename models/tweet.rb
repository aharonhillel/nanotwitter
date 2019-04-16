class Tweet < ActiveRecord::Base
    belongs_to :user
    has_many :likes, dependent: :nullify
    has_many :mentions, dependent: :nullify
    has_many :comments, dependent: :nullify
    has_many :hash_tag_tweets, dependent: :nullify
    has_many :hash_tags, through: :hash_tag_tweets
    has_many :mentions, dependent: :nullify
    has_many :mentioned_users, through: :mentions

    validates :user_id, presence: true
    validates :content, presence: true, length: {maximum: 255}
end
