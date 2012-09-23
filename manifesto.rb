require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'redis'

DOMAIN = ENV['DOMAIN'] || 'cleanweb.org.uk'

configure do
  set :sessions, true
  set :inline_templates, true
  # Redis configuration
  uri = URI.parse(ENV["REDISTOGO_URL"])
  REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end
use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
end
  
get '/' do
  erb "<a href='/auth/twitter'>Sign up using twitter</a><br>"
end
  
get '/auth/:provider/callback' do
  erb "<h1>#{params[:provider]}</h1>
       <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
end
  
get '/auth/failure' do
  erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
end
  
get '/auth/:provider/deauthorized' do
  erb "#{params[:provider]} has deauthorized this app."
end
  
get '/signed' do
  throw(:halt, [401, "Not authorized\n"]) unless session[:authenticated]
  erb "<pre>#{request.env['omniauth.auth'].to_json}</pre><hr>
       <a href='/logout'>Logout</a>"
end
  
get '/logout' do
  session[:authenticated] = false
  redirect '/'
end
