require 'spec_helper'



describe Unobservable do

  describe "#instance_events_for" do
    
    it "raises a type error when it receives a non-Module" do
      expect do
        Unobservable.instance_events_for(Object.new)
      end.to raise_error(TypeError)
    end
    


    it "returns an empty list when given a Module that does not support events" do
      plain_module = Module.new
      Unobservable.instance_events_for(plain_module, true).should be_empty
      Unobservable.instance_events_for(plain_module, false).should be_empty
    end


    it "returns an empty list when given a Module that does not have any instance events defined" do
      module_without_events = Module.new { include Unobservable::Support }
      Unobservable.instance_events_for(module_without_events, true).should be_empty
      Unobservable.instance_events_for(module_without_events, false).should be_empty
    end

    
    
    context "Module defines instance events" do
      let(:mixin_module) do
        Module.new do
          include Unobservable::Support
          attr_event :one, :two
        end
      end
      
      let(:module_with_events) do
        # Due to scoping weirdness, we need to place the mixin module
        # in a local variable first.
        m = mixin_module
        Module.new do
          include Unobservable::Support
          include m
          attr_event :three, :four
        end
      end
    
      it "returns instance events defined explicitly by the Module when all=false" do
        events = Unobservable::instance_events_for(module_with_events, false)
        events.size.should eq(2)
        events.should include(:three)
        events.should include(:four)
      end
      
      
      it "returns instance events defined explicitly and through included Modules when all=true" do
        events = Unobservable::instance_events_for(module_with_events, true)
        events.size.should eq(4)
        events.should include(:one)
        events.should include(:two)
        events.should include(:three)
        events.should include(:four)
      end
      
    end

  end
  
end