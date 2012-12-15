require 'spec_helper'

include Unobservable::SpecHelper


shared_examples_for "instance event container" do
  
  context "Unobservable::Support is not included" do
    it "does not have any instance events" do
      c = described_class.new
      Unobservable::instance_events_for(c, true).should be_empty
      Unobservable::instance_events_for(c, false).should be_empty
    end
  end
  
  
  context "Unobservable::Support is included" do

    let(:mixin_module) do
      module_with_instance_events :one, :two
    end
    
    let(:instance_event_container) do
      m = mixin_module
      described_class.new do
        include Unobservable::Support
        include m
        
        attr_event :three, :four
      end
    end

    it "does not have any events by default" do
      c = described_class.new { include Unobservable::Support }
      Unobservable::instance_events_for(c, true).should be_empty
      Unobservable::instance_events_for(c, false).should be_empty
    end
    
    it "knows which events have been defined explicitly" do
      events = Unobservable::instance_events_for(instance_event_container, false)
      events.size.should == 2
      events.should include(:three)
      events.should include(:four)
    end

    it "inherits instance events defined by included Modules" do
      events = Unobservable::instance_events_for(instance_event_container, true)
      events.size.should == 4
      events.should include(:one)
      events.should include(:two)
      events.should include(:three)
      events.should include(:four)
    end


    context "#define_event" do
      
      let(:c){ described_class.new{ include Unobservable::Support } }
      
      it "returns true if the specified event did not already exist" do
        c.send(:define_event, :quux).should be_true
      end
      
      it "returns false if the specified event already existed" do
        c.send(:define_event, :quux)
        c.send(:define_event, :quux).should be_false
      end
      
      
      it "defines an instance event" do
        c.instance_events.should_not include(:quux)
        c.send(:define_event, :quux)
        c.instance_events.should include(:quux)
      end
      
      it "creates an instance method that shares the same name as the event" do
        c.instance_methods.should_not include(:quux)
        c.send(:define_event, :quux)
        c.instance_methods.should include(:quux)
      end
      
    end

  end
  
end


describe Module do
  it_behaves_like "instance event container"
end

describe Class do
  it_behaves_like "instance event container"
end