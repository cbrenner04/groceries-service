# frozen_string_literal: true

# helper methods for authentication in request specs
module AuthenticationHelper
  def login(user)
    # TODO: deprecation warning is thrown on every test and points to this line
    #       "DEPRECATION WARNING: connection_config is deprecated and will be removed from Rails 6.2 (Use connection_db_config instead)"
    #       related to https://github.com/lynndylanhurley/devise_token_auth/pull/1467
    #       needs a version bump to take affect
    @response = post(
      user_session_path,
      params: {
        email: user.email,
        password: user.password
      }
    )
  end

  def auth_params
    client = @response.headers["client"]
    token = @response.headers["access-token"]
    expiry = @response.headers["expiry"]
    token_type = @response.headers["token-type"]
    uid = @response.headers["uid"]

    {
      "access-token" => token,
      "client" => client,
      "uid" => uid,
      "expiry" => expiry,
      "token-type" => token_type
    }
  end
end
