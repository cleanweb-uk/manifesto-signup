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
  erb "<h1>#{params[:provider]}</h1>
       <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
end
  
get '/auth/failure' do
  erb :auth_failed
end
  
get '/auth/:provider/deauthorized' do
  erb :deauthorized
end
  
get '/signed' do
  throw(:halt, [401, "Not authorized\n"]) unless session[:user]
  erb :signed
end