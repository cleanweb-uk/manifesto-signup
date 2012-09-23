require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-twitter'

DOMAIN = ENV['DOMAIN'] || 'cleanweb.org.uk'

configure do
  set :sessions, true
  set :inline_templates, true
end
use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end
  
get '/' do
  erb :index
end
  
get '/auth/:provider/callback' do
  # Get omniauth data
  auth_data = request.env['omniauth.auth']
  session[:user] = "#{auth_data['provider']}:#{auth_data['uid']}"
  # Store signature
  # TODO
  # Redirect to signed page
  redirect '/signed'
end
  
get '/auth/failure' do
  erb :auth_failed
end
  
get '/auth/:provider/deauthorized' do
  erb :deauthorized
end
  
get '/signed' do
  redirect '/' and return unless session[:user]
  erb :signed
end