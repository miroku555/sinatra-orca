#!/usr/bin/ruby
#-*-coding: utf-8-*-
$:.unshift File.dirname(__FILE__)
require 'pp'
require 'net/http'
require 'haml'
require 'sinatra'
require 'crack/xml'
require 'crack'
require 'uri'
require 'orca-api'

set :bind, '0.0.0.0'
set :public_folder, File.dirname(__FILE__) + '/static'

Net::HTTP.version_1_2

opt = {
  :host =>"192.168.4.123",
  :port =>"8000",
  :user =>"ormaster",
  :passwd =>"ormaster123"
}

get '/' do
  @patients = list_patients(opt)
  haml :index
end

get '/register' do
  haml :register
end

post '/register' do
  @patient = params
  @id,@error = register_patient(opt,@patient)
  if @error
      haml :register_result
  else
    haml :register
  end
end

get '/delete' do
  pp params
  @patient = params
  haml :delete
end

post '/delete' do
  @patient = params
  @id,@error = delete_patient(opt,@patient)
  redirect to '/'
end

