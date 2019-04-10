class CreateFollows < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.integer :user_id
      t.integer :following_id
    end
    add_index :follows, [:user_id, :following_id], unique: true
  end
end
