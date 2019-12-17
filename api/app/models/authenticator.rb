# frozen_string_literal: true

# Helper class Authenticator for parsing header keys & tokens
class Authenticator
  def initialize(authorization)
    @authorization = authorization
  end

  def api_key
    return nil unless credentials_have_api_key?

    id, key = credentials['api_key'].split(':')

    return nil unless id && key

    api_key = ApiKey.activated.get(id)

    return nil unless api_key

    return api_key if secure_compare_with_hashing(api_key.api_key, key)
  end

  def access_token
    return nil unless credentials_have_access_token?

    id, token = credentials['access_token'].split(':')

    return nil unless id && token

    user = User.get(id)

    return nil unless user && api_key

    access_token = AccessToken.first(user: user, api_key: api_key)

    check_access_token(access_token, token)
  end

  private

  def check_access_token(access_token, token)
    return nil unless access_token

    return nil if access_token.expired? && access_token.destroy

    return access_token if access_token.authenticate(token)
  end

  def credentials
    @credentials ||= Hash[@authorization.scan(/(\w+)[:=] ?"?([\w|:]+)"?/)]
  end

  def credentials_have_api_key?
    !credentials['api_key'].nil? && !credentials['api_key'].empty?
  end

  def credentials_have_access_token?
    !credentials['access_token'].nil? && !credentials['access_token'].empty?
  end

  def secure_compare_with_hashing(aaa, bbb)
    Rack::Utils.secure_compare(Digest::SHA1.hexdigest(aaa),
                               Digest::SHA1.hexdigest(bbb))
  end
end
