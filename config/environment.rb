# frozen_string_literal: true

require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require_relative '../app/app'