class User < ActiveRecord::Base
  has_many :tweets
  has_many :follows
  has_many :likes

  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :user_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following

  before_save {self.email = email.downcase, self.username = username.downcase}

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
  #
  # def following_ids
  #   res = []
  #
  #   self.following.each do |f|
  #     res.push(f.tweets)
  #   end
  #   res
  # end

  def followingTweets
    res = []
    self.following.each do |f|
      f.tweets.each do |tweet|
        res.push(tweet)
    end
    end
    byebug
    res
  end
end
