# frozen_string_literal: true

require 'sinatra'

require_relative '../models/user'

require_relative '../../version'
require_relative 'authentication'

# The application.
class App
  include Authentication

  @@ACCEPTED_MEDIA_TYPES = {
    '*/*' => :metaspace_json_v1,
    'application/*' => :metaspace_json_v1,
    'application/vnd.metaspace.v1+json' => :metaspace_json_v1
  }

  register do
    def auth(_type)
      condition do
        halt 401 unless send(type?.to_s)
      end
    end
  end

  helpers do
    def admin?
      user? && @user.admin?
    end

    def user?
      @user != nil
    end

    def user_manager?
      user? && @user.user_manager?
    end
  end

  before do
    acceptable?

    target = request.path_info.split('/')[1]
    pass if target.nil?
    pass if %w[version user_confirmations password_resets].include?(target)
    pass if request.env['REQUEST_METHOD'] == 'OPTIONS'

    @user = nil

    validate_auth_scheme
    authenticate_client

    response['Access-Control-Allow-Origin'] = '*'

    if request.request_method == 'POST'
      # puts "REQUEST BODY #{request.body.read}"
      # puts "REQUEST PARAMS #{params}"
      # request.body.rewind
      # @json = JSON.parse(request.body.read)
      # params.merge!(@json)
    end
  end

  error do
    resource_not_found
  end

  def acceptable?
    unacceptable! unless accepted_media_type
  end

  get '/' do
    'OK'
  end

  get '/version' do
    { version: Version.string }.to_json
  end

  protected

  def metaspace_json_v1(data, _options)
    data.to_json
  end

  def accepted_media_type
    @accepted_media_type ||= find_acceptable
  end

  def find_acceptable
    accept_header = request.env['HTTP_ACCEPT']
    accept = Rack::Accept::MediaType.new(accept_header).qvalues

    accept.each do |media_type, _q|
      return media_type if @@ACCEPTED_MEDIA_TYPES[media_type]
    end

    nil
  end

  def resource_not_found
    halt(404)
  end

  def unacceptable!
    accept = request.env['HTTP_ACCEPT']
    halt(406, {
      error: {
        message: "No acceptable media type in Accept header: #{accept}",
        acceptable_media_types: @@ACCEPTED_MEDIA_TYPES.keys
      }
    }.to_json)
  end

  def unprocessable_entity!(resource)
    halt(422, {
      error: {
        message: "Invalid parameters for resource #{resource.class}.",
        invalid_params: resource.errors
      }
    }.to_json)
  end
end
