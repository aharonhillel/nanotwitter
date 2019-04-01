class CreateTweets < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.references :user, foreign_key: true
      t.integer :retweet_id
      t.text :content
      t.string :img_url
      t.string :video_url
      t.date :date
      t.integer :total_likes
      t.timestamps
    end
  end
end
