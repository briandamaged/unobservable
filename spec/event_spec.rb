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


    end
  end
  
end