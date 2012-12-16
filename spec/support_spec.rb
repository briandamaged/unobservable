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


    describe "#define_singleton_event" do
      
      it "defines a new singleton event directly on the object" do
        the_singleton_event = :quux
        
        obj.class.instance_events.should_not include(the_singleton_event)
        obj.singleton_events(false).should_not include(the_singleton_event)
        expect{ obj.event(the_singleton_event) }.to raise_error
        
        expect{ obj.define_singleton_event the_singleton_event }.to change{ obj.singleton_events(false).size }.by(1)
        
        obj.class.instance_events.should_not include(the_singleton_event)
        obj.singleton_events(false).should include(the_singleton_event)
        expect{ obj.event(the_singleton_event) }.to_not raise_error
      end
      
      it "returns True if the object did not already define the event as a singleton event" do
        obj.define_singleton_event(:foo).should be_true
      end
      
      it "returns False if the object already defined the event as a singleton event" do
        obj.define_singleton_event(:foo)
        obj.define_singleton_event(:foo).should be_false
      end
      
      
      it "creates a corresponding instance method when :create_method => true" do
        obj.methods.should_not include(:quux)
        obj.define_singleton_event :quux, :create_method => true
        obj.methods.should include(:quux)
      end
      
      it "does not create a corresponding instance method when :create_method => false" do
        obj.methods.should_not include(:quux)
        obj.define_singleton_event :quux, :create_method => false
        obj.methods.should_not include(:quux)
      end
      
      it "creates a corresponding instance method by default" do
        obj.methods.should_not include(:quux)
        obj.define_singleton_event :quux
        obj.methods.should include(:quux)
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

