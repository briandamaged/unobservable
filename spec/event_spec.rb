require 'spec_helper'

module Unobservable
  
  describe Event do
    
    let(:e) { Event.new }
    
    
    describe "#register" do
      
      it "returns the event handler that was added to the event's list of handlers" do
        handler = Proc.new {}
        e.register(handler).should == handler
      end
      
      it "adds an event handler to the event's list of handlers" do
        handler = Proc.new {}
        
        expect do
          e.register(handler)
        end.to change{ e.handlers.size }.from(0).to(1)
        
        e.handlers.should include(handler)
      end
      
      it "allows multiple event handlers to be registered to the same event" do
        h1 = Proc.new { puts "one" }
        h2 = Proc.new { puts "two" }
                
        expect do
          e.register h1
          e.register h2
        end.to change{ e.handlers.size }.from(0).to(2)
        
        e.handlers.should include(h1)
        e.handlers.should include(h2)
        
        h1.should_not == h2
      end
      
      
      it "allows the same event handler to be registered multiple times" do
        handler = Proc.new {}
        
        expect do
          3.times { e.register handler }
        end.to change{ e.handlers.size }.from(0).to(3)
        
        e.handlers.each {|h| h.should == handler}
      end
      
    end
    
    
    describe "#unregister" do

      it "returns nil when asked to unregister a handler that was never registered" do
        p = Proc.new {}
        e.handlers.should_not include(p)
        e.unregister(p).should be_nil
      end

      it "returns the handler that was unregistered" do
        p = Proc.new {}
        e.register p
        
        e.handlers.should include(p)
        expect do
          e.unregister(p).should == p
        end.to change{ e.handlers.size }.from(1).to(0)
        
        e.handlers.should_not include(p)
      end
      
      
      it "only unregisters 1 occurrence of the specified event handler" do
        p = Proc.new { "hello" }
        3.times { e.register p }
                
        expect{ e.unregister p }.to change{ e.handlers.size }.from(3).to(2)
        
        e.handlers.each{|h| h.should == p}
      end

    end
    
    
    
    describe "#call" do
      it "can be called when no event handlers have been registered" do
        expect{ e.call }.to_not raise_error
        expect{ e.call 1, 2, 3 }.to_not raise_error
      end
      
      it "passes its arguments to each event handler" do
        3.times do |i|
          h = mock("handler #{i}")
          h.should_receive(:some_method).with("arg1", "arg2")
          e.register h, :some_method
        end
        
        e.call "arg1", "arg2"
      end
      
      
      it "should invoke each event handler even if one or more event handlers raise an exception." do
        3.times do |i|
          h = mock("handler #{i}")
          h.should_receive(:some_method).with("arg1", "arg2").and_raise(Exception)
          e.register h, :some_method
        end
        
        expect{ e.call "arg1", "arg2" }.to_not raise_error
      end
      
    end
    
  end
  
  
  
  
end


