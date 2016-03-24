module ControllerHelper
  def jwt_token(user)
    JsonWebToken.encode('user' => user.email)
  end

  def authorize(user)
    request.env['HTTP_AUTHORIZATION'] = "Bearer #{jwt_token(user)}"
  end

  def json
    JSON.parse(response.body)
  end

  def expect_authentication_error
    expect(response.status).to be 401
    expect(json).to eq({ 'errors' => [ I18n.t('devise.failure.unauthenticated') ] })
  end

  def expect_not_found
    expect(response.status).to be 404
    expect(json).to eq ({ 'errors' => [ I18n.t('not_found') ] })
  end
end


RSpec.configure do |config|
  config.include ControllerHelper, type: :controller
end
