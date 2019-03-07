require 'csv'
require 'faker'
require 'activerecord-import'
require_relative '../app.rb'
# require_relative 'seed_files/users.csv'

file = CSV.read File.join(File.dirname(__FILE__), '/seed_files/users.csv')
User.delete_all
puts "seeding users......hold tight"
# all_users= []
file.each do |row|
user = User.new(:username => row[1], :email => Faker::Internet.email, :id => row[0].to_i)
user.password = Faker::Lorem.word
user.save
end
