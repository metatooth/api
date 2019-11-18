# frozen_string_literal: true

# The Products endpoints.
class ProductsController < ApplicationController
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

  get '/products', auth: 'user' do
    products = Product.activated
    status 200
    products.to_json
  end

  post '/products', auth: 'admin' do
  end

  get '/products/:id', auth: 'user' do
  end

  put '/products/:id', auth: 'admin' do
  end

  delete '/products/:id', auth: 'admin' do
  end
end
