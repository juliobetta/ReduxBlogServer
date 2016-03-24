class API::UsersController < ApplicationController
  before_action :authenticate_user_from_token!, only: [:destroy, :update]

  def create
    @user  = User.new user_params
    @token = nil

    if @user.save
      generate_token
      render :show, status: :created
    else
      render_errors_for @user
    end

  end


  def destroy
    current_user.destroy
    render status: :ok
  end


  def update
    @user = current_user

    update_method = will_change_password? ? :update_with_password : :update_without_password

    if @user.send(update_method, user_params)
      generate_token
      render :show, status: :ok
    else
      render_errors_for @user
    end
  end


  private

  def user_params
    params.permit(:name, :email, :current_password, :password, :password_confirmation)
  end

  def generate_token
    @token = jwt_token(@user)
  end

  def will_change_password?
    user_params[:current_password].present? && !user_params[:current_password].empty?
  end
end
