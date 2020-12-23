# frozen_string_literal: true

# The plans endpoints.
class App
  options '/plans' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/plans/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/plans' do
    from = DateTime.parse(params[:from]) if params[:from]
    to = DateTime.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = DateTime.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    plans = plans.by_created_at(from, to)

    status 200
    { data: plans }.to_json
  end

  post '/plans' do
    request.body.rewind
    body = JSON.parse(request.body.read)
    body['data'].delete('name')
    body['data']['number'] = 0

    plan.revisions << Revision.new(body['data'])

    if plan.save
      status 200
      { data: JSON.parse(plan.to_json(methods: [:revisions])) }.to_json
    else
      plan.errors.each do |err|
        puts "ERR #{err}"
      end
      halt 500
    end
  end

  get '/plans/:id' do
    if plan
      status 200
      { data: JSON.parse(plan.to_json(methods: [:revisions])) }.to_json
    else
      resource_not_found
    end
  end

  put '/plans/:id' do
    if plan.nil?
      resource_not_found
    elsif plan.update(plan_params)
      status :ok
      { data: JSON.parse(plan.to_json(methods: [:revisions])) }.to_json
    else
      unprocessable_entity!(plan)
    end
  end

  delete '/plans/:id' do
    if plan.nil?
      resource_not_found
    else
      plan.destroy
      status :no_content
    end
  end

  private

  def plan
    @plan ||= params[:id] ? Plan.first(locator: params[:id]) : Plan.new(plan_params)
  end

  def plan_params
    return params[:data]&.slice(:name) unless params.empty?

    request.body.rewind
    check = JSON.parse(request.body.read)
    check['data']&.slice('name')
  end
end
