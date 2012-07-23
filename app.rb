require 'sinatra/base'
require 'data_mapper'

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

  end

  get '/' do
    @page_title = "Welcome to StatRoom"
    @styles = "index"
    erb :index
  end

  post '/email' do
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
  end

  #Listing email for debugging - should be removed before going to prod
  get '/email' do
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
  end

end
