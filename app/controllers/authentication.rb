# frozen_string_literal: true

# Implements authentication scheme
module Authentication
  AUTH_SCHEME = 'Metaspace-Token'

  private

  def api_key
    return nil if credentials['api_key'].nil?

    @api_key ||= ApiKey.activated.first(api_key: credentials['api_key'])
  end

  def authenticate_client
    unauthorized!('Client Realm') unless api_key
  end

  def authorization_request
    @authorization_request ||= request.env['HTTP_AUTHORIZATION'].to_s
  end

  def credentials
    @credentials ||= Hash[authorization_request.scan(/(\w+)[:=] ?"?(\w+)"?/)]
  end

  def unauthorized!(realm)
    headers['WWW-Authenticate'] = %(#{AUTH_SCHEME} realm="#{realm}")
    halt 401
  end

  def validate_auth_scheme
    return if authorization_request.match(/^#{AUTH_SCHEME} /)

    unauthorized!('Client Realm')
  end
end
