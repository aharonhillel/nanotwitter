class CreateHashTagTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_tag_tweets do |t|
      t.string :tweet_id
      t.string :hash_tag_id
    end
  end
end
