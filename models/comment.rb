class Comment < ActiveRecord::Base
  belongs_to :tweets
  validates :content, presence: true
end
