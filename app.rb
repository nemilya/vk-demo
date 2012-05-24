require 'rubygems'

require 'sinatra'
require 'yaml'
require 'omniauth-vkontakte'
require 'vkontakte_api'

enable :sessions

config_path = File.join("config", "oauth.yml")
if File.exists?(config_path)
  oauth_settings = YAML.load(File.read(config_path))

  if oauth_settings['vkontakte']
    ENV['API_KEY']    ||= oauth_settings['vkontakte']['api_key']
    ENV['API_SECRET'] ||= oauth_settings['vkontakte']['api_secret']
  end

  use OmniAuth::Builder do  
    if ENV['API_KEY']
      provider :vkontakte, ENV['API_KEY'], ENV['API_SECRET'],
        :scope => 'friends,audio,photos', :display => 'popup'
    end
  end
end

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
