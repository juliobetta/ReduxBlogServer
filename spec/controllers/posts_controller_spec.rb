require 'rails_helper'

RSpec.describe API::PostsController do
  render_views

  let(:user)   { create_user }
  let!(:object) { FactoryGirl.create(:post, user: user) }
  let(:another_user) { create_user}
  let(:another_post) { FactoryGirl.create(:post, user: another_user) }
  let(:show_object_attrs) {
    %w(id user_id content title categories created_at updated_at)
  }
  let(:list_object_attrs) {
    %w(id user_id title categories created_at updated_at)
  }


  describe 'GET #posts' do
    context 'with success' do
      it 'lists posts' do
        authorize user

        get :index, format: :json

        expect(response.status).to be 200
        expect(json).to include object.slice(*list_object_attrs)
                                      .merge(created_at: object.created_at.to_i,
                                             updated_at: object.updated_at.to_i)
                                      .stringify_keys
      end

      it 'lists only current user\'s posts' do
        authorize user

        get :index, format: :json

        attrs = another_post.slice(*list_object_attrs)
                            .merge(created_at: another_post.created_at.to_i,
                                   updated_at: another_post.updated_at.to_i)
                            .stringify_keys

        expect(response.status).to be 200
        expect(json).to_not include attrs
      end
    end

    context 'with failure' do
      context 'when auth token is not passed' do
        it 'shows authentication error' do
          get :index,format: :json
          expect_authentication_error
        end
      end
    end
  end


  ##############################################################################
  ##############################################################################


  describe 'POST #post' do
    context 'with success' do
      it 'creates a post' do
        authorize user

        attrs = FactoryGirl.attributes_for(:post, user_id: user.id)
        post :create, attrs.merge(format: :json)

        last = Post.last

        expect(response.status).to be 201
        expect(json).to eq attrs.merge(id:         last.id,
                                       created_at: last.created_at.to_i,
                                       updated_at: last.updated_at.to_i)
                                .stringify_keys
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
        authorize user
        get :show, id: object.id, format: :json

        attrs = object.attributes
                      .merge({created_at: object.created_at.to_i,
                             updated_at: object.updated_at.to_i}.stringify_keys)

        expect(response.status).to be 200
        expect(json).to eq attrs.slice(*show_object_attrs)
      end
    end

    context 'with failure' do
      context 'when post does not exist' do
        it 'shows 404' do
          authorize user
          get :show, id: 0, format: :json
          expect_not_found
        end
      end

      context 'when access another user\'s post' do
        it 'shows 404' do
          authorize user
          get :show, id: another_post, format: :json
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
        expect(json).to eq new_attrs.merge(user_id: user.id,
                                           created_at: object.created_at.to_i,
                                           updated_at: object.updated_at.to_i)
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

        attrs = object.attributes.merge(
          {
            created_at: object.created_at.to_i,
            updated_at: json['updated_at']
          }.stringify_keys
        )

        expect(response.status).to be 200
        expect(json).to eq attrs.slice(*show_object_attrs)
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
