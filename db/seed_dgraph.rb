# seed_dgraph seeds the dgraph database with the seed file
require 'csv'
require 'faker'
require_relative '../boot'
require_relative 'models/user'

# do
$dg.drop_all




def seed_users
  seed = CSV.read(File.join(File.dirname(__FILE__ ), '/seed_file/users.csv'))
  seed.each do |row|
    user = User.new(:username => row[1], :email => Faker::Internet.unique.email,
                    :password => 'password')

    $dg.mutate()
  end
end