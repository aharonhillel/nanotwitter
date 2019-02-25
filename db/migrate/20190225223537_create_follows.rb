class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.string :follower_id
      t.string :followed_id
    end
  end
end
