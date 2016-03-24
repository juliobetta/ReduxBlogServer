class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy

  devise :database_authenticatable, :registerable, :trackable, :validatable

end
