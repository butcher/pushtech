require 'test_helper'

class ReservationFlowTest < ActionDispatch::IntegrationTest

  reservation_attributes = {
    hotel_name: 'Royal',
    price: 1000,
    currency: 'eur',
    checkin_date: 2.days.since.to_date.as_json,
    checkout_date: 5.days.since.to_date.as_json,
    guest_full_name: 'Pablo Picasso',
    guest_email: 'pablo.picasso@gmail.com'
  }

  test 'renders the list of reservations' do
    Reservation.delete_all

    get '/reservations'

    assert_response :success
    assert_equal([], @response.parsed_body)

  end

  test 'fails on create with invalid data' do
    Reservation.delete_all

    get '/reservations'

    assert_response :success
    assert_equal [], @response.parsed_body

    post '/reservations', params: {reservation: {hotel_name: 'Royal'}}
    assert_response :bad_request

    error = @response.parsed_body['error']

    assert_equal 'Can not create the reservation', error['title']
    assert_equal 9, error['detail'].size

    get '/reservations'

    assert_response :success
    assert_equal([], @response.parsed_body)
  end

  test 'creates the reservation' do
    Reservation.delete_all

    get '/reservations'
    assert_response :success
    assert_equal [], @response.parsed_body

    post '/reservations', params: {reservation: reservation_attributes}
    assert_response :created
    new_reservation = @response.parsed_body
    assert_equal 'eur', new_reservation['currency']
    assert_equal 'Pablo Picasso', new_reservation['guest_full_name']
    assert_equal 'pablo.picasso@gmail.com', new_reservation['guest_email']

    get '/reservations'
    assert_response :success

    list = @response.parsed_body
    assert_equal 1, list.size
    assert_equal 'eur', list.first['currency']
    assert_equal 'Pablo Picasso', list.first['guest_full_name']
    assert_equal 'pablo.picasso@gmail.com', list.first['guest_email']
  end

  test 'fails on show' do
    Reservation.delete_all

    get "/reservations/#{BSON::ObjectId.new}"
    assert_response :not_found
  end

  test 'renders specific reservation' do
    Reservation.delete_all

    post '/reservations', params: {reservation: reservation_attributes}
    assert_response :created

    get "/reservations/#{@response.parsed_body['_id']['$oid']}"
    assert_response :ok
    reservation = @response.parsed_body
    assert_equal 'eur', reservation['currency']
    assert_equal 'Pablo Picasso', reservation['guest_full_name']
    assert_equal 'pablo.picasso@gmail.com', reservation['guest_email']
  end

  test 'fails on update the unknown reservation' do
    Reservation.delete_all

    put "/reservations/#{BSON::ObjectId.new}"
    assert_response :not_found
  end

  test 'fails on update the reservation with invalid data' do
    Reservation.delete_all

    post '/reservations', params: {reservation: reservation_attributes}
    assert_response :created

    put "/reservations/#{@response.parsed_body['_id']['$oid']}", params: {reservation: {guest_email: 'bad_email'}}
    assert_response :bad_request
  end

  test 'update the reservation' do
    Reservation.delete_all

    post '/reservations', params: {reservation: reservation_attributes}
    assert_response :created

    put "/reservations/#{@response.parsed_body['_id']['$oid']}", params: {reservation: {guest_email: 'pablo.picasso.personal@gmail.com'}}
    assert_response :ok

    get "/reservations/#{@response.parsed_body['_id']['$oid']}"
    assert_response :ok

    updated_reservation = @response.parsed_body
    assert_equal 'eur', updated_reservation['currency']
    assert_equal 'Pablo Picasso', updated_reservation['guest_full_name']
    assert_equal 'pablo.picasso.personal@gmail.com', updated_reservation['guest_email']
  end

  test 'fails on delete the reservation' do
    Reservation.delete_all

    get '/reservations'
    assert_response :success
    assert_equal [], @response.parsed_body

    delete "/reservations/#{BSON::ObjectId.new}"
    assert_response :not_found
  end

  test 'deletes the reservation' do
    Reservation.delete_all

    get '/reservations'
    assert_response :success
    assert_equal [], @response.parsed_body

    post '/reservations', params: {reservation: reservation_attributes}
    assert_response :created

    delete "/reservations/#{@response.parsed_body['_id']['$oid']}"
    assert_response :ok
  end
end
