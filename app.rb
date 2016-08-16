require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'
require 'pry'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/rental.db")

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :name, String, :required => true, :unique => true
  property :password_hash, String, :required => true, :length => 60

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

end

DataMapper.finalize
User.auto_upgrade!



class RentalApp < Sinatra::Base

  # use Rack::Session::Cookie, :key => 'rack.session',
  #                            :domain => 'localhost',
  #                            :path => '/',
  #                            :expire_after => 2592000, # In seconds
  #                            :secret => 'wgckibzwewshlmkeniyazktmlnyskgirpxkaotmfhchczjicfa'
  # set :bind, '0.0.0.0'
  # set :port, 3000
  enable :sessions
  set :session_secret, 'wgckibzwewshlmkeniyazktmlnyskgirpxkaotmfhchczjicfa'

  helpers do
    def logged_in?
      !!session[:id]
    end
  end

  get '/' do
    # binding.pry
    redirect '/login' if !logged_in?
    @user = User.get(session[:id])
    erb :index
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    # binding.pry
    user = User.first(name: params[:name])
    if user.password == params[:password]
      session[:id] = user.id
      # binding.pry
    end
    redirect '/'

  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

end









