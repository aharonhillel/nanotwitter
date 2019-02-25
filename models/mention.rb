require 'sinatra/activerecord'

class Mention < ActiveRecord::Base
  belongs_to :tweets
  belongs_to :users
end