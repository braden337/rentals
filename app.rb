require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'
require 'pry'

require 'money'
I18n.enforce_available_locales = false

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

  has n, :rentals

end

class Rental
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer, :required => true
  property :address, String, :required => true
  property :last_payment, DateTime

  belongs_to :user
  has n, :payments

end

class Payment
  include DataMapper::Resource

  property :id, Serial
  property :amount, Integer, :required => true
  property :paid_at, DateTime, :required => true
  property :rental_id, Integer, :required => true

  belongs_to :rental

end

DataMapper.finalize.auto_upgrade!
# User.auto_upgrade!



class RentalApp < Sinatra::Base

  enable :sessions
  set :session_secret, 'wgckibzwewshlmkeniyazktmlnyskgirpxkaotmfhchczjicfa'

  helpers do
    def logged_in?
      !!session[:id]
    end
    def money(amount)
      Money.new(amount, 'CAD').format
    end
  end

  get '/' do
    redirect '/login' if !logged_in?
    @user = User.get(session[:id])
    @rentals = @user.rentals.all(:order => [ :last_payment ])
    erb :index
    # binding.pry
  end

  post '/' do
    # m = Money.new(params[:amount].to_f*100, 'CAD')
    # binding.pry
    p = Payment.new(:rental_id => params[:rental], :amount => params[:amount].to_f*100, :paid_at => Time.now)
    p.save
    r = Rental.get(p.rental_id)
    r.update(:last_payment => p.paid_at)
    r.save
    redirect "/rental/#{p.rental_id}"
  end

  post '/rental' do
    Rental.create(:address => params[:address], :user_id => session[:id])
    redirect '/'
  end

  get '/rental/new' do
    erb :'rentals/new'
  end

  get '/rental/:id' do
    @rental = Rental.get(params[:id])
    redirect '/' unless logged_in? && session[:id] == @rental.user_id
    @user = User.get(session[:id])
    @payments = @rental.payments
    @sum =  @payments.map{|x| x.amount}.reduce(:+)
    # binding.pry
    erb :'rentals/show'
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
