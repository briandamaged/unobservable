require 'memoize'

include Memoize

module Unobservable
  

  
  class Event
    attr_reader :handlers
    
    def initialize
      @handlers = []
    end

    # There are 3 ways for end-users to provide an event handler:
    #
    # 1. They can pass an object that has a #call method
    # 2. They can provide an object and the name of a method to invoke
    # 3. They can pass in a block
    def handler_for(*args, &block)
      if block
        return block
      elsif args.size == 1
        return args[0]
      elsif args.size == 2
        return args[0].method(args[1])
      end
      
      raise ArgumentError, "Unable to create an event handler using the given arguments"
    end
    
    # Registers the given event handler so that it will be
    # invoked when the event is raised.
    def register(*args, &block)
      h = handler_for(*args, &block)
      @handlers << h
      return h
    end


    def unregister(*args, &block)
      h = handler_for(*args, &block)
      index = @handlers.index(h)
      if index
        @handlers.slice!(index)
        return h
      else
        return nil
      end
    end
    
    
    # Pass the specific arguments / block to all of the
    # event handlers.  Return true if there was at least
    # 1 event handler; return false otherwise.
    def call(*args, &block)
      if @handlers.empty?
        return false
      else
        # TODO: Add some form of error-handling
        @handlers.each do |h|
          h.call(*args, &block)
        end
        
        return true
      end
    end
  
    
  end
  
end