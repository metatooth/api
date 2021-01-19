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

    api_key_repo = ApiKeyRepo.new(MAIN_CONTAINER)
    api_key = api_key_repo.by_id(id)

    return nil unless api_key

    return api_key if secure_compare_with_hashing(api_key.api_key, key)
  end

  def access_token
    return nil unless credentials_have_access_token?

    id, token = credentials['access_token'].split(':')

    return nil unless id && token

    begin
      user = UserRepo.new(MAIN_CONTAINER).by_id(id)
    rescue StandardError
      user = nil
    end

    return nil unless user && api_key

    access_token = AccessTokenRepo.new(MAIN_CONTAINER)
                                  .query(user_id: user[:id],
                                         api_key_id: api_key[:id])
                                  .first

    check_access_token(access_token, token)
  end

  private

  def check_access_token(access_token, token)
    return nil unless access_token

    expired = ((access_token.created_at + 14 * 24 * 60 * 60) < Time.now)

    access_token_repo = AccessTokenRepo.new(MAIN_CONTAINER)

    return nil if expired && access_token_repo.destroy(access_token.id)

    return access_token if access_token_repo.authenticate(access_token.id,
                                                          token)
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
