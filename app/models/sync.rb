class Sync
  include Synchronizable::Base

  has_many :posts
  # has_one :user
end
