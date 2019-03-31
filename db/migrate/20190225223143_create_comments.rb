class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :tweet, foreign_key: true
      t.string :commenter_name
      t.string :reply_to_name
      t.text :content
      t.timestamps
    end
  end
end
