# frozen_string_literal: true

# Endpoints for customer addresses
class App
  get '/customers/:cid/addresses' do
    authenticate_user

    if current_customer.nil?
      resource_not_found
    else
      status 200
      { data: current_customer.addresses }.to_json
    end
  end

  get '/customers/:cid/addresses/:id' do
    authenticate_user

    if current_customer.nil?
      resource_not_found
    else
      address = current_customer.addresses.first(id: params[:id])

      if address.nil?
        resource_not_found
      else
        status 200
        { data: address }.to_json
      end
    end
  end

  post '/customers/:cid/addresses' do
    authenticate_user

    if current_customer.nil?
      resource_not_found
    else
      address.customer = current_customer

      if address.save
        path = "/customers/#{current_customer.id}/addresses/#{address.id}"
        response.headers['Location'] =
          "#{request.scheme}://#{request.host}#{path}"
        status :created
        { data: address }.to_json
      else
        unprocessable_entity!(address)
      end
    end
  end

  put '/customers/:cid/addresses/:id' do
    authenticate_user

    if current_customer.nil? ||
       address.nil? ||
       !current_customer.addresses.include?(address)
      resource_not_found
    elsif address.update(address_params)
      status :ok
      { data: address }.to_json
    else
      unprocessable_entity!(address)
    end
  end

  delete '/customers/:cid/addresses/:id' do
    authenticate_user

    if current_customer.nil? ||
       address.nil? ||
       !current_customer.addresses.include?(address)
      resource_not_found
    else
      address.destroy
      status :no_content
    end
  end

  private

  def current_customer
    @current_customer ||= Customer.get(params[:cid])
  end

  def address
    @address ||= Address.get(params[:id])
    @address ||= Address.new(address_params)
  end

  def address_params
    params[:data]&.slice(:name,
                         :organization,
                         :address1,
                         :address2,
                         :city,
                         :state,
                         :zip5,
                         :zip4,
                         :postcode)
  end
end
