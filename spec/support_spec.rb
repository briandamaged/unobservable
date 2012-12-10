require 'spec_helper'

include Unobservable::SpecHelper

module Unobservable
  describe Support do
    let(:my_class) { class_with_instance_events(:foo, :bar) }
    let(:obj) { my_class.new }

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
        expect{ obj.event(:not_exist) }.to raise_error(NameError)
      end
      
      it "maps different names to different Event instances" do
        obj.event(:foo).should_not === obj.event(:bar)
      end
      
      it "maps the same name to the same Event instance" do
        obj.event(:foo).should === obj.event(:foo)
        obj.event(:bar).should === obj.event(:bar)
      end
      
      it "maintains separate Events for each object" do
        x = my_class.new
        y = my_class.new
        
        x.event(:foo).should_not === y.event(:foo)
      end
    end
    
    
    describe "#raise_event" do
      
      it "raises a NameError when the specified event is not defined" do
        expect{ obj.send :raise_event, :not_exist }.to raise_error(NameError)
        expect{ obj.send :raise_event, :not_exist, 1, 2, 3 }.to raise_error(NameError)
      end
            
      it "calls the specified event" do
        args = [1, 2, 3]
        obj.event(:foo).should_receive(:call).with(*args)
        obj.send :raise_event, :foo, *args
      end
      
    end

  end
end

