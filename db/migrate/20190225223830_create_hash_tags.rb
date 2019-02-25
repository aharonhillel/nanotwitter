class CreateHashTags < ActiveRecord::Migration[5.2]
  def change
    create_table :hash_tags do |t|
      t.text :description
    end
  end
end
