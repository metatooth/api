# frozen_string_literal: true

# Endpoints for user addresses
class App
  get '/users/:uid/addresses' do
    authenticate_user

    if selected_user.nil?
      resource_not_found
    else
      status 200
      { data: selected_user.addresses }.to_json
    end
  end

  get '/users/:uid/addresses/:id' do
    authenticate_user

    if selected_user.nil?
      resource_not_found
    else
      address = selected_user.addresses.first(id: params[:id])

      if address.nil?
        resource_not_found
      else
        status 200
        { data: address }.to_json
      end
    end
  end

  post '/users/:uid/addresses' do
    authenticate_user

    if selected_user.nil?
      resource_not_found
    else
      address.user = selected_user

      if address.save
        path = "/users/#{selected_user.id}/addresses/#{address.id}"
        response.headers['Location'] =
          "#{request.scheme}://#{request.host}#{path}"
        status :created
        { data: address }.to_json
      else
        unprocessable_entity!(address)
      end
    end
  end

  put '/users/:uid/addresses/:id' do
    authenticate_user

    if selected_user.nil? ||
       address.nil? ||
       !selected_user.addresses.include?(address)
      resource_not_found
    elsif address.update(address_params)
      status :ok
      { data: address }.to_json
    else
      unprocessable_entity!(address)
    end
  end

  delete '/users/:uid/addresses/:id' do
    authenticate_user

    if selected_user.nil? ||
       address.nil? ||
       !selected_user.addresses.include?(address)
      resource_not_found
    else
      address.destroy
      status :no_content
    end
  end

  private

  def selected_user
    @selected_user ||= User.get(params[:uid])
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
