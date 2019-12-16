# frozen_string_literal: true

require_relative '../models/order'

# The orders endpoints.
class App
  options '/orders' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/orders' do
    authenticate_user

    from = DateTime.parse(params[:from]) if params[:from]
    to = DateTime.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = DateTime.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    orders = Order.all(customer: current_user.account.customers)
    orders.select! { |v| v.created_at > from && v.created_at < to }

    status 200
    { data: orders }.to_json
  end

  post '/orders' do
    authenticate_user
    
    order.customer = current_user
    Order = Order.new(request.body.read)
    Order.user_id = @user.id

    if Order.create
      status 200
      Order.to_json
    else
      halt 500
    end
  end

  options '/orders/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/orders/:id' do
    authenticate_user

    if order && current_user.account.customers.include?(order.customer)
      status 200
      { data: order }.to_json
    else
      resource_not_found
    end
  end

  put '/orders/:id' do
    authenticate_user

    if order.nil? || !current_user.account.customers.include?(order.customer)
      resource_not_found
    else
      if order.update(order_params)
        status :ok
        { data: order }.to_json
      else
        unprocessable_entity!(order)
      end
    end
  end

  delete '/orders/:id' do
    authenticate_user

    if order.nil? || !current_user.account.customers.include?(order.customer)
      resource_not_found
    else
      order.destroy
      status :no_content
    end
  end

  private

  def order
    @order ||= params[:id] ? Order.get(params[:id]) : Order.new(order_params)
  end

  def order_params
    params[:data]&.slice(:shipped_impression_kit_at, :received_impression_kit_at, :shipped_custom_night_guard_at)
  end
end
