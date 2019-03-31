class CreateLikes < ActiveRecord::Migration[5.2]
  def change
    create_table :likes do |t|
      t.references :tweets, foreign_key: true
      t.references :users, foreign_key: true
    end
  end
end
