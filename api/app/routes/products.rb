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
    products = Product.all
    status 200
    { data: products }.to_json
  end

  post '/products' do
    authenticate_user

    if product.save
      UserMailer.new_product(current_user, product)
      response.headers['Location'] =
        "#{request.scheme}://#{request.host}/products/#{product.locator}"
      status :created
      { data: product }.to_json
    else
      unprocessable_entity!(product)
    end
  end

  get '/products/:id' do
    if product
      status 200
      { data: product }.to_json
    else
      resource_not_found
    end
  end

  put '/products/:id' do
    authenticate_user

    if product.nil?
      resource_not_found
    elsif product.update(product_params)
      status :ok
      { data: product }.to_json
    else
      unprocessable_entity!(product)
    end
  end

  delete '/products/:id' do
    authenticate_user

    if product.nil?
      resource_not_found
    else
      product.destroy
      status :no_content
    end
  end

  private

  def product
    @product ||= Product.get(params[:id]) if params[:id]
    @product ||= Product.new(product_params) unless params[:id]
    @product
  end

  def product_params
    params[:data]&.slice(:name, :description)
  end
end
