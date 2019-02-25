require 'sinatra/activerecord'

class Like < ActiveRecord::Base
  belongs_to :tweets
  belongs_to :users
end