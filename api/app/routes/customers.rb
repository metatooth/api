# frozen_string_literal: true

# The customers endpoints.
class App
  options '/customers' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  get '/customers' do
    authenticate_user

    customers = Customer.all

    status 200
    { data: customers }.to_json
  end

  post '/customers' do
    authenticate_user
    if customer.save
      response.headers['Location'] = "#{request.scheme}://#{request.host}/customers/#{customer.id}"
      status :created
      { data: customer }.to_json
    else
      unprocessable_entity!(customer)
    end
  end

  options '/customers/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/customers/:id' do
    authenticate_user

    if customer
      status 200
      { data: customer }.to_json
    else
      resource_not_found
    end
  end

  put '/customers/:id' do
    authenticate_user

    if customer.update(customer_params)
      status :ok
      { data: customer }.to_json
    else
      unprocessable_entity!(customer)
    end
  end

  delete '/customers/:id' do
    authenticate_user
    customer.destroy
    status :no_content
  end

  private

  def customer
    @customer ||= params[:id] ? Customer.get(params[:id]) : Customer.new(customer_params)
  end

  def customer_params
    params[:data]&.slice(:name)
  end
end
