# frozen_string_literal: true

require 'sinatra/base'

class App < Sinatra::Base
  get '/' do
    'Welcome!'
  end
end