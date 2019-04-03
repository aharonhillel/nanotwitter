ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods

describe "Create new users" do
  it "can't create user with invalid email address" do
    u = User.new(username: "Bob", email: "123@somewhere", password_hash: "12345678")
    u.save.must_equal false
  end

  it "can't create user with used email address" do
    User.create(username: "Lily", email: "lily@gmail.com", password_hash: "12345678")
    u = User.new(username: "Lisa", email: "lily@somewhere", password_hash: "pwddd")
    u.save.must_equal false
  end

  it "can't create user with used username" do
    User.create(username: "Sam", email: "sam@gmail.com", password_hash: "12345678")
    u = User.new(username: "Sam", email: "sameul@gmail.com", password_hash: "12345678")
    u.save.must_equal false
  end

  it "can't create user without email address" do
    u = User.new(username: "Tim", password_hash: "12345678")
    u.save.must_equal false
  end

  it "can't create user without username" do
    u = User.new(email: "jay@gmail.com", password_hash: "12345678")
    u.save.must_equal false
  end

  it "can't create user with password shorter than 8 digits" do
    u = User.new(username: "jason", email: "jason@gmail.com", password_hash: "123")
    u.save.must_equal false
  end

  it "can create user without avatar, bio, real full name or date of birth, though they are fields in the User table" do
    u = User.new(username: "Thomas", email: "tclouga@gmail.com", password_hash: "12345678")
    u.save.must_equal true
  end

  after do
    User.destroy_all
  end
end

describe "Follower-Followee Relationships" do

  before do
    @p = User.create(username: "Follower1", email: "followeri@gmail.com", password_hash: "12345678")
    @q = User.create(username: "Follower2", email: "followerii@gmail.com", password_hash: "12345678")
    @me = User.create(username: "Irene", email: "irene@gmail.com", password_hash: "12345678")
    @f1 = Follow.new(following: @me, follower: @p)
    @f2 = Follow.create(following: @p, follower: @me)
    @f3 = Follow.create(following: @q, follower: @me)
    @a = User.create(username: "A", email: "a@gmail.com", password_hash: "12345678")
    @b = User.create(username: "B", email: "b@gmail.com", password_hash: "12345678")
    @c = User.create(username: "C", email: "c@gmail.com", password_hash: "12345678")
    @d = User.create(username: "D", email: "d@gmail.com", password_hash: "12345678")
    @f4 = Follow.create(following: @a, follower: @b)
    @f5 = Follow.create(following: @a, follower: @c)
    @f6 = Follow.create(following: @a, follower: @d)
  end

  it "can tell how many people are following me" do
    @f1.save.must_equal true
  end

  it "can tell how many people I am following " do
    @me.following.length.must_equal 2
  end

  it "cannot add duplicate followers" do
    @f3 = Follow.create(following: @me, follower: @p)
    @me.followers.length.must_equal 1
  end

  it "if @a is followed by @b, @c and @d, then @me have three followers" do
    @a.followers.length.must_equal 3
  end

  it "if @a is followed by @b, @c and @d, then @b is a follower of @a" do
    (@a.followers.include?@b).must_equal true
  end

  it "if @a is followed by @b, @c and @d, then @a is a followed user of @b" do
    (@b.following.include?@a).must_equal true
  end

  it "A user cannot follow itself" do
    @f = Follow.create(following: @a, follower: @a)
    @a.followers.length.must_equal 3
    @a.following.must_equal []
  end

  after do
    Follow.destroy_all
    User.destroy_all
  end
end

describe "Tweet" do
  before do
    @user = User.create(username: "Jack", email: "jack@gmail.com", password_hash: "12345678")
  end

  it "A user can tweet" do
    t = Tweet.new(user_id: @user.id, content: "Jack just tweet!")
    t.save.must_equal true
  end

  it "A user can have many tweets" do
    Tweet.create(user_id: @user.id, content: "Jack just tweet!")
    Tweet.create(user_id: @user.id, content: "Jack tweets again!")
    @user.tweets.length.must_equal 2
  end

  it "A user can't tweet for more than 255 characters" do
    t = Tweet.new(user_id: @user.id, content: "This tweet is too long.This tweet is too long.This tweet is too long.
This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.
This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.
This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.
This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.
This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.This tweet is too long.")
    t.save.must_equal false
  end

  after do
    Tweet.destroy_all
    User.destroy_all
  end
end

describe "Comment on tweets and response to comments" do
  before do
    @aa = User.create(username: "Aa", email: "aa@gmail.com", password_hash: "12345678")
    @bb = User.create(username: "Bb", email: "bb@gmail.com", password_hash: "12345678")
    @cc = User.create(username: "Cc", email: "cc@gmail.com", password_hash: "12345678")
    @t = Tweet.create(user_id: @aa.id, content: "Aa post a tweet!")
  end

  it "A user can comment on his/her own tweet" do
    c = Comment.new(tweet_id: @t.id, commenter_name: @aa.username, content: "I commented on myself.")
    c.save.must_equal true
  end

  it "A comment can also be commented" do
    Comment.create(tweet_id: @t.id, commenter_name: @bb.username, reply_to_name: @aa.username, content: "I commented on aa's tweet.")
    c = Comment.new(tweet_id: @t.id, commenter_name: @aa.username, reply_to_name: @bb.username, content: "I saw b's comment.")
    c.save.must_equal true
  end

  it "tweet can have many comments" do
    Comment.create(tweet_id: @t.id, commenter_name: @aa.username, content: "aa commented.")
    Comment.create(tweet_id: @t.id, commenter_name: @bb.username, content: "bb commented.")
    Comment.create(tweet_id: @t.id, commenter_name: @cc.username, content: "cc commented.")
    @t.comments.length.must_equal 3
  end

  after do
    Tweet.destroy_all
    User.destroy_all
    Comment.destroy_all
  end
end

describe "Like on tweets" do
  before do
    @u1 = User.create(username: "u1", email: "u1@gmail.com", password_hash: "12345678")
    @u2 = User.create(username: "u2", email: "u2@gmail.com", password_hash: "12345678")
    @t1 = Tweet.create(user_id: @u1.id, content: "Aa post a tweet!")
    @t2 = Tweet.create(user_id: @u2.id, content: "Bb post a tweet!")
  end

  it "A user can like many tweets, no matter who post them" do
    Like.create(tweet_id: @t1.id, user_id: @u1.id)
    Like.create(tweet_id: @t2.id, user_id: @u1.id)
    @u1.likes.length.must_equal 2
  end

  it "A user can't like the same tweet more than once" do
    Like.create(tweet_id: @t2.id, user_id: @u2.id)
    l = Like.new(tweet_id: @t2.id, user_id: @u2.id)
    l.save.must_equal false
  end

  after do
    Tweet.destroy_all
    User.destroy_all
    Like.destroy_all
  end
end

describe "Mention user(s) when posting tweet" do
  before do
    @u3 = User.create(username: "u3", email: "u3@gmail.com", password_hash: "12345678")
    @u4 = User.create(username: "u4", email: "u4@gmail.com", password_hash: "12345678")
    @u5 = User.create(username: "u5", email: "u5@gmail.com", password_hash: "12345678")
    @t3 = Tweet.create(user_id: @u3.id, content: "u3 post a tweet!")
    @t4 = Tweet.create(user_id: @u4.id, content: "u4 post a tweet!")
    @t5 = Tweet.create(user_id: @u3.id, content: "u3 post a tweet!")
  end

  # it "can't mention a user that doesn't exist" do
  #   m = Mention.new(tweet_id: @t3.id, mentioned_user: "nobody")
  #   m.save.must_equal false
  # end

  it "can't mention anyone before tweet is posted" do
    t = Tweet.new(user_id: @u5.id, content: "u5 composes a tweet!")
    m = Mention.new(tweet_id: t.id, user_id: @u4.id)
    m.save.must_equal false
  end

  it "can mention more than one user in one" do
    Mention.create(tweet_id: @t3.id,user_id: @u3.id)
    Mention.create(tweet_id: @t3.id, user_id: @u4.id)
    Mention.create(tweet_id: @t3.id, user_id: @u5.id)
    @t3.mentioned_users.length.must_equal 3
  end

  it "can list all tweets that mentions an user" do
    Mention.create(tweet_id: @t3.id, user_id: @u5.id)
    Mention.create(tweet_id: @t4.id, user_id: @u5.id)
    Mention.create(tweet_id: @t5.id, user_id: @u5.id)
    @u5.mentioned_in_tweets.length.must_equal 3
  end

  after do
    Tweet.destroy_all
    User.destroy_all
    Mention.destroy_all
  end
end

describe "Create hashtags in tweets and collect tweets with hashtags" do
  before do
    @h1 = HashTag.create(description: "Ruby")
    @h2 = HashTag.create(description: "Sinatra")
    @u6 = User.create(username: "u6", email: "u6@gmail.com", password_hash: "12345678")
    @u7 = User.create(username: "u7", email: "u7@gmail.com", password_hash: "12345678")
    @t6 = Tweet.create(user_id: @u6.id, content: "u6 post a tweet!")
    @t7 = Tweet.create(user_id: @u6.id, content: "u6 post a tweet!")
    @t8 = Tweet.create(user_id: @u6.id, content: "u6 post a tweet!")
    @t9 = Tweet.create(user_id: @u6.id, content: "u6 post a tweet!")
  end

  it "can't create hashtag that's longer than 20 characters" do
    h = HashTag.new(description: "123456789012345678901")
    h.save.must_equal false
  end

  it "won't create duplicate hashtags" do
    h = HashTag.new(description: "Ruby")
    h.save.must_equal false
  end

  # it "if a hashtag is created for the first time, it must be created after the creation of tweet" do
  #
  #   Tweet.new(user_id: @u6.id, content: "u2 is composing a tweet about #Cheesecake.")
  #   h = HashTag.new(description: "Cheesecake")
  #   h.save.must_equal false
  # end

  it "hashtag_tweet must be created after the creation of tweet and hashtag" do

    t = Tweet.create(user_id: @u6.id, content: "u2 is composing a tweet about #Cheesecake.")
    h = HashTag.new(description: "Cheesecake")
    ht = HashTagTweet.new(tweet_id: t.id, hash_tag_id: h.id)
    ht.save.must_equal false
  end

  it "can list all hashtags contained in a tweet" do
    HashTagTweet.create(tweet_id: @t6.id, hash_tag_id: @h1.id)
    HashTagTweet.create(tweet_id: @t6.id, hash_tag_id: @h2.id)
    @t6.hash_tags.length.must_equal 2
  end

  it "can list all tweets under a hashtag" do
    HashTagTweet.create(tweet_id: @t7.id, hash_tag_id: @h1.id)
    HashTagTweet.create(tweet_id: @t6.id, hash_tag_id: @h1.id)
    HashTagTweet.create(tweet_id: @t8.id, hash_tag_id: @h1.id)
    HashTagTweet.create(tweet_id: @t9.id, hash_tag_id: @h1.id)
    @h1.tweets.length.must_equal 4
  end

  after do
    Tweet.destroy_all
    User.destroy_all
    HashTag.destroy_all
    HashTagTweet.destroy_all
  end
end



