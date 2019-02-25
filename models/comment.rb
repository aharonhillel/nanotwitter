require 'sinatra/activerecord'

class Comment < ActiveRecord::Base
  belongs_to :tweets
  belongs_to :users, through: :tweets
  validates :content, presence: true
end