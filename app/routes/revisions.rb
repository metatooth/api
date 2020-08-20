# frozen_string_literal: true

require_relative '../models/revision'

# The revisions endpoints.
class App
  options '/plans/:pid/revisions' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/plans/:pid/revisions/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/plans/:pid/revisions' do
    from = DateTime.parse(params[:from]) if params[:from]
    to = DateTime.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = DateTime.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    revisions = Plan.first(locator: params[:pid]).revisions
    revisions.select! { |v| v.created_at > from && v.created_at < to }

    status 200
    { data: revisions }.to_json
  end

  post '/plans/:pid/revisions' do
    plan = Plan.first(locator: params[:pid])
    revision
    revision.plan = plan
    revision.number = plan.latest + 1

    if revision.save
      status 200
      revision.to_json
    else
      revision.errors.each do |err|
        puts "ERR #{err}"
      end

      halt 500
    end
  end

  get '/plans/:pid/revisions/:id' do
    if revision
      status 200
      { data: revision }.to_json
    else
      resource_not_found
    end
  end

  put '/plans/:pid/revisions/:id' do
    if revision.nil?
      resource_not_found
    elsif revision.update(revision_params)
      status :ok
      { data: revision }.to_json
    else
      unprocessable_entity!(revision)
    end
  end

  delete '/plans/:pid/revisions/:id' do
    if revision.nil?
      resource_not_found
    else
      revision.destroy
      status :no_content
    end
  end

  private

  def revision
    @revision ||= params[:id] ? Revision.first(locator: params[:id]) : Revision.new(revision_params)
  end

  def revision_params
    begin
      request.body.rewind
      check = JSON.parse(request.body.read)
    rescue StandardError
      check = params
    end
    check['data']&.slice('number', 'description', 'location', 'mime_type',
                         'service', 'bucket', 's3key')
  end
end
