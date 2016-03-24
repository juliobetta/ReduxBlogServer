json.extract! @user, :id, :name, :email
json.set! :token, @token || nil
