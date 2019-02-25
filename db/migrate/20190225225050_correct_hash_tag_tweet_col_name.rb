class CorrectHashTagTweetColName < ActiveRecord::Migration[5.2]
  def change
    change_table :hash_tag_tweets do |t|
      t.string :hashtag_id, :hash_tag_id
    end
  end
end
