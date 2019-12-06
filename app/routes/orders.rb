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
    from = Time.parse(params[:from]) if params[:from]
    to = Time.parse(params[:to]) if params[:to]

    # :NOTE: 20190605 Terry: Inclusive of the 'to' date.

    to += 24 * 60 * 60 if to

    now = Time.now
    from ||= now - 30 * 24 * 60 * 60
    to ||= now

    @orders = Order.all
    @orders.select! { |v| v.completed_on > from && v.completed_on < to }

    status 200
    @orders.to_json
  end

  post '/orders' do
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
    if (Order = Order.get(params[:id]))
      if @user.type == 'Admin' || @user.id == Order.user_id
        status 200
        Order.to_json
      else
        halt 401
      end
    else
      halt 500
    end
  end

  put '/orders/:id' do
    if (Order = Order.get(params[:id]))
      if @user.type == 'Admin' || @user.id == Order.user_id
        vars = JSON.parse(request.body.read)
        Order.description = vars['description']
        Order.completed_on = Time.parse(vars['completed_on'])
        Order.duration = vars['duration']
        if Order.update
          status 200
          Order.to_json
        else
          halt 500
        end
      else
        halt 401
      end
    else
      halt 500
    end
  end

  delete '/orders/:id' do
    if (Order = Order.get(params[:id]))
      if @user.type == 'Admin' || @user.id == Order.user_id
        status 204 if Order.destroy
      else
        halt 401
      end
    else
      halt 500
    end
  end
end
