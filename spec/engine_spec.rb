require 'spec_helper'

module EMS
  describe Engine do
    subject(:engine) { Engine.new }

    before(:each) do
      EMS.nodes[:test_node] = [:foo, :bar]
      EMS.nodes[:test_node2] = [:foo, :baz]
    end

    ## GLOBALS
    context "when a global is set" do
      let(:global) { Object.new }

      before(:each) do
        engine.set_global(global)
      end

      it { should have_global(:object) }

      it "should allow the global to be got" do
        expect(engine.get_global(:object)).to eq(global)
      end

      context "when the global is unset" do
        before(:each) do
          engine.unset_global(:object)
        end

        it { should_not have_global(:object) }
      end
    end
    ## /GLOBALS

    ## ENTITIES + NODES
    context "after an entity has been added" do

      # ENTITIES
      let(:entity) { Entity.new }

      before(:each) do
        entity[:foo] = Object.new
        entity[:bar] = Object.new
        engine.add_entity(entity)
      end

      it { should have_entity(entity.id) }

      it "should allow the entity to be got" do
        expect(engine.get_entity(entity.id)).to eq(entity)
      end

      it "should include entity in recognised node list" do
        expect( engine.get_node_list(:test_node) ).to_not be_empty
      end

      it "should not include entity in unrecognised node list" do
        expect( engine.get_node_list(:test_node2) ).to be_empty
      end

      context "when the entity is removed" do
        before(:each) do
          engine.remove_entity(entity.id)
        end

        it { should_not have_entity(entity.id) }

        it "should remove entity from recognised node list" do
        expect( engine.get_node_list(:test_node) ).to be_empty
        end
      end

      # NODES
      context "after a node list has been accessed" do
        before(:each) do
          engine.get_node_list(:test_node)
          engine.get_node_list(:test_node2)
        end

        context "when a key component is removed from the entity" do
          before(:each) do
            entity.remove_component(:foo)
          end

          it "should remove the entity from the appropriate node list" do
            expect( engine.get_node_list(:test_node) ).to be_empty
          end
        end

        context "when key components are added to the entity" do
          before(:each) do
            entity[:baz] = Object.new
          end

          it "should add the entity to the appropriate node list" do
            expect( engine.get_node_list(:test_node2) ).to_not be_empty
          end
        end
      end
    end
    ## /ENTITIES + NODES

    ## THREADS
    context "when a thread is added" do
      let(:thread) { Thread.new }

      before(:each) do
        engine.add_thread(thread)
      end

      it { should have_thread(thread.id) }

      it "should allow the thread to be got" do
        expect(engine.get_thread(thread.id)).to eq(thread)
      end

      context "when the thread is removed" do
        before(:each) do
          engine.remove_thread(thread.id)
        end

        it { should_not have_thread(thread.id) }
      end

      context "when update is called" do

        it "should update the thread" do
          thread.should_receive(:update)
          engine.update
        end
      end

      context "when the engine is shut down" do

        it "should shut down each thread" do
          thread.should_receive(:shut_down)
          engine.shut_down
        end

        it "should remove all threads" do
          engine.shut_down
          expect(engine).to_not have_thread(thread.id)
        end
      end
    end
    ## /THREADS
  end
end
