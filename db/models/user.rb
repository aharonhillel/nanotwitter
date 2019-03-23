class User
  attr_accessor :username, :email, :full_name, :dob, :bio
  attr_reader :type
  attr_writer :password

  @type = 'User'

  def create
    
  end
end