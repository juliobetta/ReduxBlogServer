class API::PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :destroy, :update]
  before_action :authenticate_user_from_token!

  def index
    @posts = Post.last(10).reverse
  end


  def show
  end


  def create
    @post = Post.new(post_params)

    if @post.save
      render :show, status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end


  def update
    if @post.update_attributes post_params
      render :show, status: :ok
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end


  def destroy
    @post.destroy
    render :show, status: :ok
  end



  private

  def set_post
    @post = Post.where(id: params[:id], user: current_user)[0]
  end

  def post_params
    params.permit(:title, :categories, :content, :key).merge(user: current_user
  end
end
