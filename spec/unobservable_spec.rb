require 'spec_helper'


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
      Module.new do
        include Unobservable::Support
        attr_event :one, :two
      end
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

  end
  
end


describe Module do
  it_behaves_like "instance event container"
end

describe Class do
  it_behaves_like "instance event container"
end


describe Unobservable do

  describe "#instance_events_for" do
    
    it "raises TypeError when it receives a non-Module" do
      expect{ Unobservable.instance_events_for(Object.new) }.to raise_error(TypeError)
    end
    
  end
  
end

