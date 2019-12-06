# frozen_string_literal: true

# The Products endpoints.
class App
  options '/products' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, POST'
  end

  options '/products/:id' do
    response['Access-Control-Allow-Origin'] = '*'
    response['Access-Control-Allow-Headers'] = 'Content-Type,Authorization'
    response['Access-Control-Allow-Methods'] = 'GET, PUT, DELETE'
  end

  get '/products' do
    products = Product.activated
    status 200
    products.to_json
  end

  post '/products' do
  end

  get '/products/:id' do
  end

  put '/products/:id' do
  end

  delete '/products/:id' do
  end
end
