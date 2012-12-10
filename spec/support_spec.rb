require 'spec_helper'

include Unobservable::SpecHelper

module Unobservable
  describe Support do
    
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
    
    
    describe "#raise_event" do
      let(:x) { class_with_instance_events(:foo).new }
      
      it "raises a NameError when the specified event does not exist" do
        expect{ x.send :raise_event, :bar }.to raise_error(NameError)
        expect{ x.send :raise_event, :bar, 1, 2, 3 }.to raise_error(NameError)
      end
      
      it "does not raise an error when the specified event exists" do
        expect{ x.send :raise_event, :foo }.to_not raise_error
        expect{ x.send :raise_event, :foo, 1, 2, 3 }.to_not raise_error
      end
      
    end

  end
end

