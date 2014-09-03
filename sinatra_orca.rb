#!/usr/bin/ruby
#-*-coding: utf-8-*-
$:.unshift File.dirname(__FILE__)
require 'pp'
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
  @patiens = list_patiens(HOST,PORT,USER,PASSWD)
  haml :index
end

