require 'rails_helper'

RSpec.describe API::PostsController do
  render_views

  let(:user)   { create_user }
  let(:object) { FactoryGirl.create(:post, user: user) }
  let(:object_attributes) { %w(id user_id content title categories) }


  describe 'POST #post' do
    context 'with success' do
      it 'creates a post' do
        authorize user

        attrs = FactoryGirl.attributes_for(:post, user_id: user.id)
        post :create, attrs.merge(format: :json)

        expect(response.status).to be 201
        expect(json).to eq attrs.merge(id: Post.last.id).stringify_keys
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          attrs = FactoryGirl.attributes_for(:post, user: user)
          post :create, attrs.merge(format: :json)

          expect_authentication_error
        end
      end
    end
  end


  ##############################################################################
  ##############################################################################


  describe 'GET #post' do
    context 'with success' do
      it 'shows a post' do
        get :show, id: object.id, format: :json

        expect(response.status).to be 200
        expect(json).to eq object.attributes.slice(*object_attributes)
      end
    end

    context 'with failure' do
      context 'when post does not exist' do
        it 'shows 404' do
          get :show, id: 0, format: :json
          expect_not_found
        end
      end
    end
  end


  ##############################################################################
  ##############################################################################


  describe 'PATCH #post' do
    let(:new_attrs) {
      {
        id:         object.id,
        format:     :json,
        title:      'Updated Title',
        categories: 'Updated Categories',
        content:    'Updated Content'
      }
    }

    context 'with success' do
      it 'updates a post' do
        authorize user

        patch :update, new_attrs

        expect(response.status).to be 200
        expect(json).to eq new_attrs.merge(user_id: user.id)
                                    .except(:format)
                                    .stringify_keys
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          patch :update, new_attrs

          expect_authentication_error
        end
      end

      context 'when post does not exist' do
        it 'shows 404' do
          authorize user
          patch :update, new_attrs.merge(id: 0)
          expect_not_found
        end
      end
    end
  end


  ##############################################################################
  ##############################################################################


  describe 'DELETE #post' do
    context 'with success' do
      it 'deletes a post' do
        authorize user
        delete :destroy, id: object.id, format: :json

        expect(response.status).to be 200
        expect(json).to eq object.attributes.slice(*object_attributes)
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          delete :destroy, id: object.id, format: :json
          expect_authentication_error
        end
      end

      context 'when post does not exist' do
        it 'shows 404' do
          authorize user
          delete :destroy, id: 0, format: :json
          expect_not_found
        end
      end
    end
  end
end
