require 'rails_helper'


RSpec.describe API::SessionsController do
  render_views

  let(:password) { 'strong_password' }
  let(:user) {
    FactoryGirl.create(:user, password: password,
                              password_confirmation: password)
  }

  before(:each) { request.env['devise.mapping'] = Devise.mappings[:user] }


  describe 'POST #session' do
    context 'with success' do
      it 'authenticates user' do
        post :create, { email: user.email, password: password, format: :json }

        expect(response.status).to be 200
        expect(json).to eq user.attributes
                               .slice(*%w(id email name token))
                               .merge(token: jwt_token(user))
                               .stringify_keys
      end
    end

    context 'with failure' do
      context 'when password is wrong' do
        it 'shows error message' do
          post :create, { email: user.email, password: 'wrong password' }

          expect(response.status).to be 401
        end
      end

      context 'when email is wrong' do
        it 'shows error message' do
          post :create, { email: 'wrongemail', password: password }

          expect(response.status).to be 401
        end
      end
    end
  end

end
