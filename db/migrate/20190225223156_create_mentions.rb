class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.references :tweet, foreign_key: true
      t.references :user, foreign_key: true
      # t.string :mentioned_user, index: {unique: true}
    end
  end
end
