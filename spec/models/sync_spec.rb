require 'rails_helper'

describe Sync do

  it 'tests' do
    user = FactoryGirl.create(:user)

    params = {
      posts: [
        FactoryGirl.attributes_for(:post, user: user, id: 1),
        FactoryGirl.attributes_for(:post, user: user, id: 2)
      ]
    }

    sync = Sync.new user, params
    p sync
  end

end
