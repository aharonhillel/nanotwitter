require 'csv'
require 'faker'
require 'activerecord-import'
require_relative '../app.rb'
# require_relative 'seed_files/users.csv'


file = CSV.read File.join(File.dirname(__FILE__), '/seed_files/tweets.csv')
Tweet.delete_all
tweets= []
puts "seeding tweets......hold tight"
file.each do |row|
tweets<< Tweet.new(:user_id => row[0].to_i, :content => row[1])
# Tweet.create(:user_id => row[0].to_i, :content => row[1])
end

Tweet.import tweets, recursive: true
