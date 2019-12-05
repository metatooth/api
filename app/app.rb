# frozen_string_literal: true

require 'sinatra/base'

class App < Sinatra::Base
  run! if $PROGRAM_NAME == __FILE__
end
