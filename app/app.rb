# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/activerecord'
require_relative 'models'
require_relative 'information_updater'

class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  
  get '/' do
    'Welcome!'
  end
end
