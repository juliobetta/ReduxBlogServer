class API::SessionsController < Devise::SessionsController
  skip_before_filter :authenticate_user_from_token!

  # @url /api/v1/sessions
  # @action POST
  #
  # Create a new json web token
  #
  # @response [JsonWebToken] jwt token
  #
  def create
    @user = User.find_for_database_authentication(email: params[:email])

    if @user && @user.valid_password?(params[:password])
      @token = jwt_token(@user)
      render 'api/users/show', status: :ok
    else
      invalid_login_attempt
    end
  end


  private

  def invalid_login_attempt
    render json: {errors: [t('devise.failure.not_found_in_database')]}, status: :unauthorized
  end
end
