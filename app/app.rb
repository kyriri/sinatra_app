# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/activerecord'
require_relative 'models'

class App < Sinatra::Base
  get '/' do
    'Welcome!'
  end
end
