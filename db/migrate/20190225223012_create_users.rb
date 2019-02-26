class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :full_name
        t.date :dob
      t.string :bio
      t.date :api_token
      t.string :password
    end
  end
end
