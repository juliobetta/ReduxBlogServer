class Sync
  include Synchronizable::Base

  has_fields :posts


  def run
    process_fields @params
  end
end
