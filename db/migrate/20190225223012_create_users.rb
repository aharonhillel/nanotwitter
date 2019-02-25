class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :user do |t|
    t.string :user_name
    t.string :email
    t.string :full_name
      t.date :dob
    t.stirng :bio
    t.date :api_token
    t.string :password
  end
  end
end
