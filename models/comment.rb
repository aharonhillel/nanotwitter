class Comment < ActiveRecord::Base
  belongs_to :tweet
  validates :content, presence: true
end
