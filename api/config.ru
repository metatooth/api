# frozen_string_literal: true

require './init'

$stdout.sync = true

Dir.glob('./app/{helpers,controllers,models}/*.rb').each { |file| require file }

map('/accounts') { run AccountsController }
map('/addresses') { run AddressesController }
map('/order_items') { run OrderItemsController }
map('/orders') { run OrdersController }
map('/users') { run UsersController }
map('/') { run ApplicationController }