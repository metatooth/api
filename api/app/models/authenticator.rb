# frozen_string_literal: true

# Helper class Authenticator for parsing header keys & tokens
class Authenticator
  def initialize(authorization)
    @authorization = authorization
  end

  def api_key
    return nil if credentials['api_key'].nil? || credentials['api_key'].empty?

    id, key = credentials['api_key'].split(':')
    api_key = id && key && ApiKey.activated.get(id)

    return api_key if api_key && secure_compare_with_hashing(api_key.api_key, key)
  end

  def access_token
    return nil if credentials['access_token'].nil? || credentials['access_token'].empty?

    id, token = credentials['access_token'].split(':')
    user = id && token && User.get(id)
    access_token = user && api_key && AccessToken.first(user: user,
                                                        api_key: api_key)
    return nil unless access_token

    if access_token.expired?
      access_token.destroy
      return nil
    end

    return access_token if access_token.authenticate(token)
  end

  private

  def credentials
    @credentials ||= Hash[@authorization.scan(/(\w+)[:=] ?"?([\w|:]+)"?/)]
  end

  def secure_compare_with_hashing(aaa, bbb)
    Rack::Utils.secure_compare(Digest::SHA1.hexdigest(aaa), Digest::SHA1.hexdigest(bbb))
  end
end
