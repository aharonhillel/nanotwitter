# generate_dgraph generates a seed file for dgraph
require 'csv'
require 'faker'
require 'date'

@generated_seed = File.open(File.join(File.dirname(__FILE__ ), 'seed.rdf'), "w")
@usersNum = {}


def generate_users(n)
  seed = CSV.read(File.join(File.dirname(__FILE__), '/seed_files/users.csv'))

  p "generating users..."
  i = 0
  seed.each do |row|
    if i == n
      break
    end

    name = "name00#{i}"

    @generated_seed.puts(
      "_:#{name} <Username> \"#{row[1].downcase}\" .",
      "_:#{name} <Email> \"#{Faker::Internet.unique.email}\" .",
      "_:#{name} <Password> \"password\" .",
      "_:#{name} <Type> \"User\" ."
    )

    @usersNum[row[0]] = name

    if i % 50 == 0
      p "generating user #{i/10.0}%"
    end
    i = i + 1
  end
  p "done generating users"
  Faker::UniqueGenerator.clear
end


def generate_tweets
  seed = CSV.read(File.join(File.dirname(__FILE__), '/seed_files/tweets.csv'))

  p "generating tweets..."
  i = 0
  seed.each do |row|
    user = @usersNum[row[0]]
    date = DateTime.parse(row[2]).rfc3339(5)
    tweet_id = "tweet00#{i}"

    if user.nil?
      next
    end

    @generated_seed.puts(
      "_:#{tweet_id} <Text> \"#{row[1]}\" .",
      "_:#{tweet_id} <Type> \"Tweet\" .",
      "_:#{tweet_id} <Timestamp> \"#{date}\" .",
      "_:#{user} <Tweet> _:#{tweet_id} ."
    )

    if i % 1000 == 0
      p "generating tweet #{i/1001.75}%"
    end
    i = i + 1
  end
  p "done generating tweets"
end


def generate_follows
  seed = CSV.read(File.join(File.dirname(__FILE__), '/seed_files/follows.csv'))

  p "generating follows..."
  i = 0
  seed.each do |row|
    f1 = @usersNum[row[0]]
    f2 = @usersNum[row[1]]

    if f1.nil? || f1.nil?
      next
    end

    @generated_seed.puts(
      "_:#{f1} <Follow> _:#{f2} ."
    )

    if i % 200 == 0
      p "generating follows #{i/49.23}%"
    end
    i = i + 1
  end
  p "done generating follows"
end

def generate_seed(num_of_users)
  generate_users(num_of_users)
  generate_tweets
  generate_follows
end

# generate
if __FILE__ == $0
  generate_seed(1000)
end
