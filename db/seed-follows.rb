require 'csv'
require 'faker'
require 'activerecord-import'
require 'byebug'
require_relative '../app.rb'
# require_relative 'seed_files/users.csv'

byebug


file = CSV.read File.join(File.dirname(__FILE__), '/seed_files/follows.csv')
Follow.delete_all
all_follow= []
puts "seeding followers......hold tight"
file.each do |row|
all_follow<< Follow.new(:user_id => row[0].to_i, :following_id => row[1].to_i)
end
Follow.import all_follow, recursive: true
