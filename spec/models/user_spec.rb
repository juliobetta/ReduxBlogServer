require 'rails_helper'

describe User do
  subject { FactoryGirl.build(:user) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to have_many(:posts).dependent(:destroy) }

end
