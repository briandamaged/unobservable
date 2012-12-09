require 'spec_helper'

module Unobservable
  
  describe Event do
    
    let(:e) { Event.new }
    
    describe "#handler_for" do
      it "raises an ArgumentError when it does not receive any arguments" do
        expect{ e.handler_for() }.to raise_error(ArgumentError)
      end


      it "raises an ArgumentError when it is receives an argument that cannot be converted into a Proc" do
        expect{ e.handler_for(Object.new) }.to raise_error(ArgumentError)
      end
      
      it "allows a Proc to be used has an event handler" do
        p = Proc.new {}
        e.handler_for(p).should == p
      end
      
      it "allows a Block to be used as an event handler" do
        p = Proc.new {}
        e.handler_for(&p).should == p
      end
      
      it "can use a specified method on an object as an event handler" do
        x = Object.new
        e.handler_for(x, :class).should == x.method(:class)
      end
      
      
      it "raises an ArgumentError when it receives 3 or more arguments" do
        expect{ e.handler_for(Proc.new, :foo, :bar) }.to raise_error(ArgumentError)
      end


    end
    
    
    describe "#register" do
      
      it "returns the event handler that was added to the event's list of handlers" do
        handler = Proc.new {}
        e.register(handler).should == handler
      end
      
      it "adds an event handler to the event's list of handlers" do
        handler = Proc.new {}
        e.handlers.size.should == 0
        
        e.register(handler)
        
        e.handlers.size.should == 1
        e.handlers.should include(handler)
      end
      
      it "allows multiple event handlers to be registered to the same event" do
        h1 = Proc.new { puts "one" }
        h2 = Proc.new { puts "two" }
        
        e.handlers.size.should == 0
        
        e.register h1
        e.register h2
        
        e.handlers.size.should == 2
        e.handlers.should include(h1)
        e.handlers.should include(h2)
        
        h1.should_not == h2
      end
      
      
      it "allows the same event handler to be registered multiple times" do
        handler = Proc.new {}
        
        e.handlers.size.should == 0
        
        3.times { e.register handler }
        
        e.handlers.size.should == 3
        3.times {|i| e.handlers[i].should == handler }
      end
      
    end
  end
  
end


