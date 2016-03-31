class API::Sync::PostsUpController < ApplicationController
  before_action :authenticate_user_from_token!

  def update
    # TODO
    render :update, status: :ok
  end


  private

  def params_from_sync
  end
end
