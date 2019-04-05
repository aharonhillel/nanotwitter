class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :full_name
        t.date :dob
      t.string :bio
      t.date :api_token
      t.string :password_hash
      t.string :avatar_url
    end

    add_index :users, [:username, :email], unique: true
    #execute "ALTER TABLE users ADD PRIMARY KEY (username);"
  end
end
