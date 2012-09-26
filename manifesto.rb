require 'rubygems'
require 'sinatra'
require 'json'
require 'omniauth'
require 'omniauth-twitter'
require 'mongoid'
require './signee'
require 'dotenv'

Dotenv.load

Mongoid.load!('mongoid.yml', :development)

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
  if Signee.find_by(:twitter_id => auth_data['uid']).nil?
    s = Signee.create( 
      :twitter_id   => auth_data['uid'],
      :name         => auth_data['info']['name'],
      :nickname     => auth_data['info']['nickname'],    
      :location     => auth_data['info']['location'],
      :description  => auth_data['info']['description'],
      :image        => auth_data['info']['image'],
      :twitter_url  => auth_data['info']['urls']['Twitter'],
      :website      => auth_data['info']['urls']['Website']
    )
  end

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
  @count = Signee.count
  erb :signed
end

get '/signatories' do
  @count = Signee.count
  @signatories = Signee.all.reverse
  erb :signatories, :layout => false
end

get '/count' do
  @count = Signee.count
  erb :count, :layout => false
end
