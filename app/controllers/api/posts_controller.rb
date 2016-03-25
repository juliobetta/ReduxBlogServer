class API::PostsController < ApplicationController
  before_action :authenticate_user_from_token!
  before_action :set_post, only: [:show, :destroy, :update]


  def index
    @posts = Post.where(user: current_user).last(10).reverse
  end


  def show
  end


  def create
    @post = Post.new(post_params)

    if @post.save
      render :show, status: :created
    else
      render_errors_for @post
    end
  end


  def update
    if @post.update_attributes post_params
      render :show, status: :ok
    else
      render_errors_for @post
    end
  end


  def destroy
    @post.destroy
    render :show, status: :ok
  end



  private

  def set_post
    @post = Post.find_by! id: params[:id], user_id: current_user.id
  end

  def post_params
    params.permit(:title, :categories, :content, :key).merge(user: current_user)
  end
end
