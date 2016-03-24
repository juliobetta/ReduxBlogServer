RSpec.configure do |config|

  def it_validates_email(allow_nil = true)
    context 'email validation' do
      %w(email@email. emai@.com mail).each do |invalid_email|
        it { is_expected.to_not allow_value(invalid_email).for(:email) }
      end

      it { is_expected.to allow_value('email@example.com').for(:email) }

      if allow_nil
        it { is_expected.to allow_value(nil).for(:email) }
      else
        it { is_expected.to validate_presence_of(:email) }
      end
    end
  end


  def create_user(role = :user)
    user = FactoryGirl.create(:user)
    user
  end
end
