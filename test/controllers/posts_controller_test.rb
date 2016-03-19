require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    @post = posts(:one)
    @controller = API::PostsController.new
  end

  test "should get index" do
    get :index, format: :json
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should get new" do
    get :new, format: :json
    assert_response :success
  end

  test "should create post" do
    assert_difference('Post.count') do
      post :create, post: { categories: @post.categories, content: @post.content, title: @post.title }
    end

    assert_response :success
  end

  test "should show post" do
    get :show, id: @post, format: :json
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @post, format: :json
    assert_response :success
  end

  test "should update post" do
    patch :update, id: @post, post: { categories: @post.categories, content: @post.content, title: @post.title }
    assert_response :success
  end

  test "should destroy post" do
    assert_difference('Post.count', -1) do
      delete :destroy, id: @post
    end

    assert_response :success
  end
end
