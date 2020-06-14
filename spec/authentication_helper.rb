# frozen_string_literal: true

# helper methods for authentication in request specs
module AuthenticationHelper
  def login(user)
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
