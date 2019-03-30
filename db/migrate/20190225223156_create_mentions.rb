class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.integer :tweet_id
      t.integer :user_id
    end
  end
end
