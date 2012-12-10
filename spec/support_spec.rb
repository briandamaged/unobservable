require 'spec_helper'

include Unobservable::SpecHelper

module Unobservable
  describe Support do
    let(:x) { class_with_instance_events(:foo, :bar).new }

    context "when included by a module" do
      it "causes the module to extend Unobservable::ModuleSupport" do
        m = Module.new{ include Unobservable::Support }

        m.should include(Unobservable::Support)
        m.singleton_class.should include(Unobservable::ModuleSupport)
      end
    end

    
    context "when extended by an Object" do
      it "causes the object's singleton class to extend Unobservable::ModuleSupport" do
        x = Object.new
        x.extend Unobservable::Support

        x.singleton_class.should include(Unobservable::Support)
        x.singleton_class.singleton_class.should include(Unobservable::ModuleSupport)
      end
    end
    
    
    describe "#event" do
      it "raises a NameError when the specified event is not defined" do
        expect{ x.event(:not_exist) }.to raise_error(NameError)
      end
      
      it "maps different names to different Event instances" do
        x.event(:foo).should_not === x.event(:bar)
      end
      
      it "maps the same name to the same Event instance" do
        x.event(:foo).should === x.event(:foo)
        x.event(:bar).should === x.event(:bar)
      end
      
      
    end
    
    
    describe "#raise_event" do
      
      
      it "raises a NameError when the specified event is not defined" do
        expect{ x.send :raise_event, :not_exist }.to raise_error(NameError)
        expect{ x.send :raise_event, :not_exist, 1, 2, 3 }.to raise_error(NameError)
      end
            
      it "calls the specified event" do
        args = [1, 2, 3]
        x.event(:foo).should_receive(:call).with(*args)
        x.send :raise_event, :foo, *args
      end
      
    end

  end
end

