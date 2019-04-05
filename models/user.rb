class User < ActiveRecord::Base
  #self.primary_key = "username"

  has_many :tweets, dependent: :nullify
  has_many :follows, dependent: :nullify
  has_many :likes, dependent: :nullify

  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :user_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following

  has_many :mentions, dependent: :nullify
  has_many :mentioned_in_tweets, through: :mentions

  validates :username, presence: true, uniqueness: true, length: {maximum: 12}
  validates :password_hash, presence: true, length: {minimum: 8}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+\.[a-z]+\z/i
  validates :email, presence: true, length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: {case_sensitive: false}

  include BCrypt

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def following_ids
    res = []
    self.following.each do |f|
      res.push(f.id)
    end
    res
  end

  def followingTweets
    Tweet.where("user_id IN (?)", following_ids).includes(:user)

    # query = "
    # # SELECT users.username, tweets.user_id, tweets.retweet_id, tweets.content, tweets.img_url,
    # #    tweets.video_url, tweets.date, tweets.total_likes, tweets.created_at, tweets.updated_at
    # # FROM tweets, users
    # # WHERE tweets.user_id IN (
    # #   SELECT following_id
    # #   FROM users, follows
    # #   WHERE follows.user_id = #{self.id})
    # # AND tweets.user_id = users.id;
    # # "
    # # ActiveRecord::Base.connection.execute(query)

    # User.select(
    #     [
    #         User.arel_table[:username], Tweet.arel_table[:user_id], Tweet.arel_table[:retweet_id], Tweet.arel_table[:content], Tweet.arel_table[:img_url], Tweet.arel_table[:video_url], Tweet.arel_table[:date], Tweet.arel_table[:total_likes], Tweet.arel_table[:created_at], Tweet.arel_table[:updated_at]
    #     ]
    # ).where(
    #     Tweet.arel_table[:user_id].in(
    #         Follow.select(:following_id).where(
    #             Follow.arel_table[:user_id].eq(self.arel_table[:id])
    #         ).ast
    #     ).and(
    #         Tweet.arel_table[:user_id].eq(User.arel_table[:id])
    #     )
    # )

  end

end
