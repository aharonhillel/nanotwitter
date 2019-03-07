class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.user_id!= record.following_id
      record.errors[:user_id] << 'A user cannot follow himself!'
    end
  end
end

class Follow < ActiveRecord::Base

  belongs_to :follower, foreign_key: 'user_id', class_name: 'User'
  belongs_to :following, foreign_key: 'following_id', class_name: 'User'

  validates :user_id, uniqueness: { scope: :following_id }
  validates_with MyValidator


end
