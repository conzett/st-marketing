require 'sinatra/base'

class Website < Sinatra::Base

  helpers do
    def put_stylesheet(style)
      result = ""
      if style.is_a?(Array)
        style.each do |name|
          result += "<link rel='stylesheet' href='css/#{name}.css' >\n"
        end
      else
        result += "<link rel='stylesheet' href='css/#{style}.css'>\n"
      end

      return result;
    end
  end

  get '/' do
    @page_title = "Welcome to StatRoom"
    @styles = "index"
    erb :index
  end

end
