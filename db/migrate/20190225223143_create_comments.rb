class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :tweets, foreign_key: true
      t.text :content
    end
  end
end
