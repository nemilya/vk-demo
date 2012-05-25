require 'rubygems'

require 'sinatra'
require 'yaml'
require 'omniauth-vkontakte'
require 'vkontakte_api'

enable :sessions

require 'init_vk'

before do
  @app = VkontakteApi::Client.new(session[:token]) if session[:token]
end

get '/' do
  erb :index
end

get '/logout' do
  session[:token] = nil
  session[:name] = nil
  redirect '/'
end

get '/auth/:name/callback' do
  auth_hash = request.env['omniauth.auth']
  session[:token] = auth_hash[:credentials][:token]
  session[:name] = auth_hash[:info][:name]
  redirect '/'
end
