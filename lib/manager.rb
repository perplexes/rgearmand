require 'rubygems'
require 'sinatra'
require 'haml'
require 'sinatra/static_assets'
require 'less'
require "sinatra/reloader"
require 'json'

use Rack::Lint

class Manager < Sinatra::Base
  
  configure do
    BASE_DIR = File.dirname(__FILE__) + "/.."
    PLUGIN_DIR = BASE_DIR + "/plugins"
    LOGGER = Logger.new("sinatra.log")
  end

  helpers do
    def logger
      LOGGER
    end

    def load_plugin(job_type)
      plugin_file = PLUGIN_DIR + "/#{job_type}.rb"
      if File.exists?(plugin_file)
        require plugin_file
        return true
      else
        return false
      end
    end
  end

  set :public, BASE_DIR + '/static'

  # Methods
  get '/' do
    @queues = QUEUES
    haml :index
  end
  
  get '/queues/:queue' do
    (@function_name, @priority) = params[:queue].split(/:/)
    puts "Function: #{@function_name}"
    queue = QUEUES[@function_name][@priority.to_sym]
    puts "Queue: #{queue}"
    @jobs = queue.to_a.collect { |e| e[:value] }
    puts "Jobs: #{@jobs.inspect}"
    haml :queue
  end

end

__END__

@@ layout
%html
  %head
    %title Gearman Job Queue
    %meta{"http-equiv"=>"Content-Type", 
       :content=>"text/html; charset=utf-8"}/
    = stylesheet_link_tag '/css/jsonstyle.css'
    = stylesheet_link_tag '/css/stylesheet.css'
    = javascript_script_tag '/js/json-min.js'
    = javascript_script_tag '/js/BubbleTooltips.js'
    = javascript_script_tag '/js/parse.js'
  %div{:id => "header"}
    %h1 Gearman manager
  %div{:id => "menu"}
    %ul 
      %li 
        %a{:title => "Job Queues", :href => "/jobs"} Job Queues
  %div{:id => "body"}   
    = yield
