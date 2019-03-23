class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_join_table :tweets, :users, table_name: :mentions do |t|
      t.index :tweet_id
      t.index :user_id
      t.timestamps
    end
  end
end
