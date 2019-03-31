class CreateHashTagTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_tag_tweets do |t|
      t.references :tweets, foreign_key: true
      t.references :hash_tags, foreign_key: true
    end
  end
end
