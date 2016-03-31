class API::Sync::PostsUpController < ApplicationController
  before_action :authenticate_user_from_token!

  def index
    @posts = Post.where(user: current_user)
  end
end
