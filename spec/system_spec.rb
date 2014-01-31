require 'spec_helper'

module EMS
  describe System do
    subject(:system) { System.new }

    it "should have an id" do
      expect(system.id).to_not be_nil
    end
  end
end
