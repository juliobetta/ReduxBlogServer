json.set! :id,    @user.id
json.set! :email, @user.email
json.set! :name,  @user.name
json.set! :token, @token || nil
