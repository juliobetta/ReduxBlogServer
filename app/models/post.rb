require 'obscenity/active_model'

class Post < ActiveRecord::Base
  belongs_to :user

  OBSCENITY_OPTS = { obscenity: { sanitize: true, replacement: "$!@*&" } }

  validates :title,      OBSCENITY_OPTS
  validates :categories, OBSCENITY_OPTS
  validates :content,    OBSCENITY_OPTS

  validates_presence_of :title, :content

end
