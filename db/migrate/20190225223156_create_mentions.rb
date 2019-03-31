class CreateMentions < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.references :tweets, foreign_key: true
      t.string :mentioned_user, index: {unique: true}
    end
  end
end
