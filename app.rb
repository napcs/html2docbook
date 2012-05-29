require 'sinatra'
require 'haml' 
require './lib/html_to_docbook'

JQUERY = "http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"
JQUERY_UI = "http://ajax.googleapis.com/ajax/libs/jqueryui/1.7.2/jquery-ui.min.js"

set :haml, {:format => :html5 }

get '/stylesheets/app.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :app
end

get '/' do
  if @code.nil?
    @code = %Q{<h1>This is a chapter</h1><p>This is an intro paragraph</p><h2>This is section 1</h2><p>This is section 1's first paragraph.</p><h3>This is a subsection of section 1</h3><p>And this is its paragraph.</p><h2>This is section 2</h2><p>And this is section 2's first paragraph!</p>}
  end
  haml :index
  
end

post "/" do
  @code = params[:code]
  
  begin
    @xml = HtmlToDocbook.new(@code).convert
  rescue
    @xml = "I think you have some bad markup up there. I can't understand what you're trying to do. Sorry!"
  end
  
  haml :index
end


