require 'sinatra'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'bcrypt'
require 'pry'
require 'SecureRandom'
require 'yaml/store'
require 'money'

I18n.enforce_available_locales = false

DataMapper::setup(
  :default,
  "sqlite3://#{Dir.pwd}/rental.db"
)

class User
  include DataMapper::Resource
  include BCrypt

  property :id, Serial
  property :name, String, {
    :required => true,
    :unique => true
  }
  property :password_hash, String, {
    :required => true,
    :length => 60
  }

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  has n, :rentals
  has 1, :configuration

end

class Configuration
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :email, String
  property :gravatar, String, :length => 60
  property :tax, Integer

  belongs_to :user
end

class Rental
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer, :required => true
  property :address, String, :required => true
  property :tenant, String
  property :rent, Integer
  property :last_payment, DateTime
  property :commercial, Boolean
  property :property_tax_annual, Integer
  property :insurance_annual, Integer

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

class RentalApp < Sinatra::Base

  enable :sessions

  store = YAML::Store.new('config.yml')

  store.transaction do
    store['secret'] ||= SecureRandom.base64(45)
    set :session_secret, store['secret']
  end

  helpers do
    def logged_in?
      !!session[:id]
    end
    def money(amount)
      Money.new(amount, 'CAD').format
    end
    def dollars_to_cents(dollars)
      (dollars.to_f*100).to_i
    end
  end

  get '/' do
    unless logged_in?
      erb :welcome
    else
      @user = User.get(session[:id])
      @rentals = @user.rentals.all(
        :order => [ :last_payment ]
      )
      erb :index
    end
  end

  post '/' do
    p = Payment.new(
      :rental_id => params[:rental],
      :amount => dollars_to_cents(params[:amount]),
      :paid_at => Time.now
    )
    p.save
    r = Rental.get(p.rental_id)
    r.update(:last_payment => p.paid_at)
    r.save
    # redirect "/rental/#{p.rental_id}"
    redirect '/'
  end

  post '/rental' do
    Rental.create(
      :user_id => session[:id],
      :address => params[:address]
    )
    redirect '/'
  end

  get '/rental/new' do
    @user = User.get(session[:id])
    erb :'rentals/new'
  end

  get '/rental/:id' do
    @rental = Rental.get(params[:id])
    unless logged_in? && session[:id] == @rental.user_id
      redirect '/'
    end
    @user = User.get(session[:id])
    @payments = @rental.payments
    @sum =  @payments.map{|x| x.amount}.reduce(:+)
    erb :'rentals/show'
  end

  get '/register' do
    erb :register
  end

  post '/register' do
    user = User.new(name: params[:name])
    if params[:password] == params[:password_confirmation]
      user.password = params[:password]
    end
    user.save

    gravatar_hash = Digest::MD5.hexdigest(params[:email])
    conf = Configuration.new(
      user_id: user.id,
      email: params[:email],
      gravatar: "https://gravatar.com/avatar/#{gravatar_hash}"
    )
    conf.save

    session[:id] = user.id
    redirect '/'
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.first(name: params[:name])
    if user.password == params[:password]
      session[:id] = user.id
    end
    redirect '/'
  end

  get '/logout' do
    session.clear
    redirect '/login'
  end

end
