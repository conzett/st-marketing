require 'sinatra/base'
require 'data_mapper'
require 'gibbon'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

# Email model
class Email
  include DataMapper::Resource

  property :id, Serial
  property :name, Text, :required => true
  property :email, String, :required => true
  property :created_at, DateTime
end

DataMapper.auto_upgrade!

class Website < Sinatra::Base

  helpers do

    def put_stylesheet(style)
      result = ""
      unless style.nil? or style.empty?
        if style.is_a?(Array)
          style.each do |name|
            result += "<link rel='stylesheet' href='css/#{name}.css' >\n"
          end
        else
          result += "<link rel='stylesheet' href='css/#{style}.css'>\n"
        end
      end

      return result;
    end

    # Basic authentication
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not Authorized"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['taivara','taivara']
    end
  end

  get '/' do
    @page_title = "Welcome to StatRoom"
    @styles = "index"
    erb :index
  end

  post '/email' do

    @apikey = 'b96cbe384e7275a350dc4995f82cb1af-us5'
    @testList = 'aa0fc43b23'
    @statRoom = '68f22152ce'

    gb = Gibbon.new(@apikey)
    subscribe = gb.listSubscribe({
      :id => @statRoom,
      :email_address => params[:email],
      :merge_vars => {
        :name => params[:name],
      }
    })

    if subscribe == true
      status 201
      "Thank you for signing up with StatRoom. A confirmation email has been sent to #{params[:email]}."
    else
      if subscribe['code'] == 230 or subscribe['code'] == 214
        halt 400, "This email address has already been used."
      elsif subscribe['code'] == 502
        halt 400, "This email address is not valid."
      else
        halt 500, "An unknown error has occured. Please try again later."
      end
    end
=begin
    email = Email.new(
      :name => params[:name],
      :email => params[:email]
    )

    if email.save
      status 201
      "Thank you, #{params[:name]}. An email will be sent to #{params[:email]} when StatRoom launch."
    else
      status 400
      "An error has occur while saving your email address."
    end
=end
  end

  get '/email' do
    redirect '/'

=begin
    protected!
    result = <<RESULT
<div class='container'>
<div class='row'>
<div class='span12'>
<table class='table table-striped'>
<thead><tr><th>Name</th><th>Email</th></tr></thead>
RESULT
    Email.all.each do |res|
      result += "<tr><td>"
      result += res.name + "</td><td>"
      result += res.email + "</td></tr>"
    end
    result += "</table>
</div>
</div>
</div>"
    erb result
=end
  end
end
