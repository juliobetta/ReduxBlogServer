class User < ActiveRecord::Base
  has_many :posts

  devise :database_authenticatable, :registerable, :trackable, :validatable
end
