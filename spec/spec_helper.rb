require 'rspec'
require 'unobservable'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end


module Unobservable
  module SpecHelper
    
    def module_with_instance_events(*names)
      Module.new do
        include Unobservable::Support
        attr_event *names
      end
    end

    def class_with_instance_events(*names)
      args = {superclass: Object}
      args.merge!(names.pop) if names[-1].is_a? Hash

      Class.new(args[:superclass]) do
        include Unobservable::Support
        attr_event *names
      end
    end
    
  end
end
