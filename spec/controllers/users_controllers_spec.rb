require 'rails_helper'

RSpec.describe API::UsersController do
  render_views
  let(:current_password) { 'current_password' }
  let(:user) {
    FactoryGirl.create(:user, password: current_password,
                              password_confirmation: current_password)
  }


  describe 'POST #user' do
    context 'with success' do
      it 'creates a user' do
        attrs = FactoryGirl.attributes_for(:user)
        post :create, attrs.merge(format: :json)

        user = User.last

        expect(response.status).to be 201
        expect(json).to eq attrs.merge(id: user.id, token: jwt_token(user))
                                .except(:password, :password_confirmation)
                                .stringify_keys
      end
    end
  end


  ##############################################################################
  ##############################################################################


  describe 'GET #user' do
    context 'with success' do
      let(:user_information) {
        {
          id: user.id,
          name: user.name,
          email: user.email,
          token: jwt_token(user)
        }.stringify_keys
      }

      it 'gets current user information' do
        authorize user
        get :show, id: user, format: :json

        expect(response.status).to be 200
        expect(json).to eq user_information
      end


      it 'shows always the current user\'s information' do
        another_user = create_user

        authorize user
        get :show, id: another_user, format: :json

        expect(response.status).to be 200
        expect(json).to eq user_information
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          get :show, id: user

          expect_authentication_error
        end
      end
    end
  end

  ##############################################################################
  ##############################################################################


  describe 'DELETE #user' do
    context 'with success' do
      it 'deletes a user' do
        authorize user

        expect {
          delete :destroy, id: user
        }.to change(User, :count).by(-1)

        expect(response.status).to be 200

      end

      it 'deletes always the current user' do
        authorize user

        expect {
          delete :destroy, id: 0
        }.to change(User, :count).by(-1)

        expect(response.status).to be 200
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          delete :destroy, id: user

          expect_authentication_error
        end
      end
    end

  end


  ##############################################################################
  ##############################################################################


  describe 'PATCH #user' do
    let(:new_attrs) {
      {
        id: user.id,
        format: :json,
        name: 'New Name',
        email: 'new@email.com'
      }
    }

    context 'with success' do
      it 'updates a user' do
        authorize user
        patch :update, new_attrs

        user.reload

        expect(response.status).to be 200
        expect(json).to eq new_attrs.merge(token: jwt_token(user))
                                    .except(:format)
                                    .stringify_keys
      end

      context 'when password attrs are set' do
        it 'changes user password' do
          password_attrs = {
            password: 'new_password',
            password_confirmation: 'new_password',
            current_password: current_password
          }

          authorize user
          patch :update, new_attrs.merge(password_attrs)

          user.reload

          expect(response.status).to be 200
          expect(json).to eq new_attrs.merge(token: jwt_token(user))
                                      .except(:format)
                                      .stringify_keys
        end
      end
    end

    context 'with failure' do
      context 'when password confirmation is wrong' do
        it 'shows error message' do
          password_attrs = {
            password: 'new_password',
            password_confirmation: 'wrong_new_password',
            current_password: current_password
          }

          authorize user
          patch :update, new_attrs.merge(password_attrs)

          expect(response.status).to be 422
        end
      end

      context 'when current password is wrong' do
        it 'shows error message' do
          password_attrs = {
            password: 'new_password',
            password_confirmation: 'new_password',
            current_password: 'wrong_current_password'
          }

          authorize user
          patch :update, new_attrs.merge(password_attrs)

          expect(response.status).to be 422
        end
      end
    end

  end

end
