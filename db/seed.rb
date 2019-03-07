require 'csv'
require_relative '../app.rb'
require_relative 'seed_files/users.csv'

byebug
CSV.foreach("seed_files/users.csv") do |row|
  byebug
  puts 'dogs are cool' if row[0] == 'dog'
  puts "your animal is a #{row[0]}"
end
