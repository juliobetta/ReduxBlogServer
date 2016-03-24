require 'json_web_token'

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }


  protected

  def authenticate_user_from_token!
    if claims and user = User.find_by(email: claims[0]['user'])
      @current_user = user
    else
      invalid_authentication
    end
  end


  def jwt_token(user)
    JsonWebToken.encode('user' => user.email)
  end


  def claims
    auth_header = request.headers['Authorization'] and
    token = auth_header.split(' ').last and
    JsonWebToken.decode(token)
  rescue
    nil
  end


  def invalid_authentication
    render json: {errors: [t('devise.failure.unauthenticated')]}, status: :unauthorized
  end


  def render_errors_for model
    render json: { errors: model.errors.full_messages }, status: :unprocessable_entity
  end
end
