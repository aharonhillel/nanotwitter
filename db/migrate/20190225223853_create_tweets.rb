class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweet do |t|
    t.integer :user_id
    t.integer :retweet_id
    t.text :content
    t.string :img_url
    t.string :video_url
    t.integer :mention_id
    t.date :date
    t.integer :total_likes
  end
  end
end
