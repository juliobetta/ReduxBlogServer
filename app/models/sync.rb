class Sync
  include Synchronizable::Base

  with_many :posts
  # with_one :user
end
