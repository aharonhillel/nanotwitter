require 'csv'
require_relative '../app.rb'
# require_relative 'seed_files/users.csv'

file = CSV.read File.join(File.dirname(__FILE__), '/seed_files/users.csv')
# Parse problem
data = CSV.parse file, headers: true

data.each do |row|
  puts 'dogs are cool' if row[0] == 'dog'
  puts "your animal is a #{row[0]}"
end
