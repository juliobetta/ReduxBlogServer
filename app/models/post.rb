require 'obscenity/active_model'

class Post < ActiveRecord::Base
  belongs_to :user

  validates :title,  obscenity: { sanitize: true, replacement: "kitten" }
  validates :categories,  obscenity: { sanitize: true, replacement: "kitten" }
  validates :content,  obscenity: { sanitize: true, replacement: "kitten" }
end
