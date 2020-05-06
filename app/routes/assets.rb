# frozen_string_literal: true

require_relative '../models/asset'

# The assets endpoints.
class App
  options '/assets' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/assets/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/assets' do
    from = DateTime.parse(params[:from]) if params[:from]
    to = DateTime.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = DateTime.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    assets = Asset.all
    assets.each do |a|
      puts "ASSET #{a.inspect}"
    end
    
    assets.select! { |v| v.created_at > from && v.created_at < to }

    status 200
    { data: assets }.to_json
  end

  post '/assets' do
    puts "ASSET #{asset.inspect}"
    if asset.save
      status 200
      asset.to_json
    else
      halt 500
    end
  end

  get '/assets/:id' do
    if asset
      status 200
      { data: asset }.to_json
    else
      resource_not_found
    end
  end

  put '/assets/:id' do
    if asset.nil?
      resource_not_found
    elsif asset.update(asset_params)
      status :ok
      { data: asset }.to_json
    else
      unprocessable_entity!(asset)
    end
  end

  delete '/assets/:id' do
    if asset.nil?
      resource_not_found
    else
      asset.destroy
      status :no_content
    end
  end

  private

  def asset
    @asset ||= params[:id] ? Asset.get(params[:id]) : Asset.new(asset_params)
  end

  def asset_params
    request.body.rewind
    check = JSON.parse(request.body.read)
    check['data']&.slice('url', 'name', 'mime_type')
  end
end
