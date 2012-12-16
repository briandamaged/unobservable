require 'set'

module Unobservable

  # Produces a list of instance events for any module regardless of whether or
  # not that module includes the Unobservable::ModuleSupport mixin.  If
  # include_supers = true, then the list will also contain instance events
  # defined by superclasses and included modules.  By default, include_supers = true
  def self.instance_events_for(mod, all = true)
    raise TypeError, "Only modules and classes can have instance_events" unless mod.is_a? Module

    contributors = [mod]
    if all
      contributors += mod.included_modules
      if mod.is_a? Class
        parent = mod.superclass
        while parent
          contributors.push parent
          parent = parent.superclass
        end
      end
    end

    self.collect_instance_events_defined_by(contributors)
  end


  # Produces a list of instance events that are explicitly defined by at least
  # one of the specified modules.
  def self.collect_instance_events_defined_by(contributors)
    retval = Set.new
    
    contributors.each do |c|
      if c.instance_variable_defined? :@unobservable_instance_events
        c.instance_variable_get(:@unobservable_instance_events).each do |e|
          retval.add(e)
        end
      end
    end
    
    return retval.to_a
  end


  # There are 3 ways for end-users to provide an event handler:
  #
  # 1. They can pass an object that has a #call method
  # 2. They can provide an object and the name of a method to invoke
  # 3. They can pass in a block
  def self.handler_for(*args, &block)
    if block
      return block
    elsif args.size == 1
      candidate = args[0]
      if candidate.respond_to?(:to_proc)
        return candidate.to_proc
      else
        raise ArgumentError, "The argument does not respond to the #to_proc method"
      end
    elsif args.size == 2
      return args[0].method(args[1])
    end

    raise ArgumentError, "Unable to create an event handler using the given arguments"
  end



  # This module is a mixin that provides support for "instance events".
  module ModuleSupport
    
    def instance_events(all = true)
      Unobservable.instance_events_for(self, all)
    end


    private
    
    
    def define_event(name, args = {})
      args = {:create_method => true}.merge(args)
      name = name.to_sym
      
      if args[:create_method]
        define_method name do
          return event(name)
        end
      end
      
      @unobservable_instance_events ||= Set.new
      if @unobservable_instance_events.include? name
        return false
      else
        @unobservable_instance_events.add name
        return true
      end
    end
    
    
    # This helper method is similar to attr_reader and attr_accessor.  It allows
    # for instance events to be declared inside the body of the class.
    def attr_event(*names)
      args = (names[-1].is_a? Hash) ? names.pop : {}
      names.each {|n| define_event(n, args) }
      return nil
    end

  end



  module Support

    # When an individual object EXTENDS the Support module, then
    # we must ensure that the object's singleton class EXTENDS
    # ModuleSupport.
    def self.extended(obj)
      obj.singleton_class.extend ModuleSupport
    end
    
    # When a class/module INCLUDES the Support module, then we
    # must ensure that the class/module also EXTENDS ModuleSupport.
    def self.included(other_mod)
      other_mod.extend ModuleSupport
    end
    

    # Obtains the list of events that are unique to this object.
    # If all = true, then this list will also include events that
    # were defined within a module that the object extended.
    def singleton_events(all = true)
      if all
        contributors  = self.singleton_class.included_modules
        contributors -= self.class.included_modules
        contributors.push self.singleton_class
        Unobservable.collect_instance_events_defined_by(contributors)
      else
        Unobservable.collect_instance_events_defined_by([self.singleton_class])
      end
    end

    # Defines an event directly on the object.
    def define_singleton_event(name, args = {})
      self.singleton_class.send(:define_event, name, args)
    end

    # Obtains the names of the events that are supported by this object.  If
    # all = false, then this list will only contain the names of the instance
    # events that are explicitly defined by the object's class.
    def events(all = true)
      self.singleton_class.instance_events(all)
    end
    
    
    # Returns the Event that has the specified name.  A NameError will be raised
    # if the object does not define any event that has the given name.
    def event(name)
      @unobservable_events_map ||= {}
      e = @unobservable_events_map[name]
      if not e
        if self.events.include? name
          e = Event.new
          @unobservable_events_map[name] = e
        else
          raise NameError, "Undefined event: #{name}"
        end
      end
      return e
    end

    private
    
    # Calls the Event that has the specified name.  A NameError will be raised
    # if the object does not define any event that has the given name.
    def raise_event(name, *args, &block)
      event(name).call(*args, &block)
    end

  end
  
  




  # Minimalistic Event implementation
  class Event
    attr_reader :handlers

    def initialize
      @handlers = []
    end



    # Registers the given event handler so that it will be
    # invoked when the event is raised.
    def register(*args, &block)
      h = Unobservable.handler_for(*args, &block)
      @handlers << h
      return h
    end
    
    alias :add :register


    # Removes a single instance of the specified event handler
    # from the list of event handlers.  Therefore, if you've
    # registered the same event handler 3 times, then you will
    # need to unregister it 3 times as well.
    def unregister(*args, &block)
      h = Unobservable.handler_for(*args, &block)
      index = @handlers.index(h)
      if index
        @handlers.slice!(index)
        return h
      else
        return nil
      end
    end


    alias :delete :unregister

    
    # Pass the specific arguments / block to all of the
    # event handlers.  Return true if there was at least
    # 1 event handler; return false otherwise.
    def call(*args, &block)
      if @handlers.empty?
        return false
      else
        # TODO: Add some form of error-handling
        @handlers.each do |h|
          begin
            h.call(*args, &block)
          rescue Exception
            # TODO: Should probably log when this happens
          end
        end

        return true
      end
    end


  end
  


end


