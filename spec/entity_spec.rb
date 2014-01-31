require 'spec_helper'

module EMS
  describe Entity do
    subject(:entity) { Entity.new }

    before(:each) do
      EMS.nodes[:test_node] = [:foo, :bar]
    end

    it "should have an id" do
      expect(entity.id).to_not be_nil
    end

    context "when a component is added" do
      let(:component) { Object.new }

      before(:each) do
        entity.add_component(component)
      end

      it { should have_component(:object) }

      it "should allow the component to be got" do
        expect(entity[:object]).to_not be_nil
      end

      context "when the component is removed" do
        before(:each) do
          entity.remove_component(:object)
        end

        it { should_not have_component(:object) }
      end
    end

    context "when key components are added" do
      before(:each) do
        entity[:foo] = Object.new
        entity[:bar] = Object.new
      end

      it "should match the appropriate node" do
        expect(entity.matches_node?(:test_node)).to eq(true)
      end

      context "when a key component is removed" do
        before(:each) do
          entity.remove_component(:foo)
        end

        it "should not match the appropriate node" do
          expect(entity.matches_node?(:test_node)).to eq(false)
        end
      end
    end
  end
end
