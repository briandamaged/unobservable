require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module PlainModule
end



class BoringClass
end

class PlainClass < BoringClass
end


describe Unobservable, "#instance_events_for" do

  it "returns an empty list when given a Module that does not include Unobservable::Support" do
    Unobservable.instance_events_for(PlainModule).should eq( [] )
  end

  it "returns an empty list when given a Class that does not include Unobservable::Support" do
    Unobservable.instance_events_for(PlainClass).should eq( [] )
  end
  
end