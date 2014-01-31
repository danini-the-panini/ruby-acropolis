require 'spec_helper'

module EMS
  describe Thread do
    subject(:thread) { Thread.new }

    let(:engine) { Engine.new }

    it "should have an id" do
      expect(thread.id).to_not be_nil
    end

    context "when a system is added" do
      let(:system) { System.new }

      before(:each) do
        thread.add_system(system)
      end

      it { should have_system(system.id) }

      it "should allow the system to be got" do
        expect(thread.get_system(system.id)).to_not be_nil
      end

      context "when the system is removed" do
        before(:each) do
          thread.remove_system(system.id)
        end

        it { should_not have_system(system.id) }
      end

      context "when update is called" do
        it "should update each system" do
          system.should_receive(:update)
          thread.update(engine)
        end
      end
    end
  end
end
