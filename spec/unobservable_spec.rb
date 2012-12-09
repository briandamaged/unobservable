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
  
  
  describe "#collect_instance_events_defined_by" do
    let(:mixin_module) do
      module_with_instance_events(:mixin_1, :mixin_2)
    end
    
    let(:baseclass) do
      class_with_instance_events(:bc_1, :bc_2)
    end
    
    let(:subclass) do
      m = mixin_module
      class_with_instance_events(:sc_1, :sc_2, superclass: baseclass) do
        include m
      end
    end
    
    
    it "only collects the instance events that the contributors define explicitly" do
      events = Unobservable::collect_instance_events_defined_by([subclass])
      events.size.should == 2
      events.should include(:sc_1)
      events.should include(:sc_2)
    end
    
    it "collects the instance events defined by each contributor" do
      classes = (1..3).map{|i| class_with_instance_events("a#{i}", "b#{i}") }
      modules = (1..3).map{|i| module_with_instance_events("c#{i}", "d#{i}") }
      
      events = Unobservable::collect_instance_events_defined_by(classes + modules)
      events.size.should == 12
      (1..3).each do |i|
        events.should include("a#{i}".to_sym)
        events.should include("b#{i}".to_sym)
        events.should include("c#{i}".to_sym)
        events.should include("d#{i}".to_sym)
      end
    end
    
    
    it "does not repeat duplicate instance events" do
      c1 = class_with_instance_events(:one, :two)
      c2 = class_with_instance_events(:one, :three)
      m1 = module_with_instance_events(:two, :three)
      m2 = module_with_instance_events(:two)
      
      events = Unobservable::collect_instance_events_defined_by([c1, c2, m1, m2])
      events.size.should == 3
      events.should include(:one)
      events.should include(:two)
      events.should include(:three)
    end


  end
  
end

