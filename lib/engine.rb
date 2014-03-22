# The MIT License
#
# Copyright 2013 Daniel Smith <jellymann@gmail.com>.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'helper'
require_relative 'ems'

module EMS

  # This class is the heart of the Entity Component System. It is an aggregation
  # of entities (as well as nodes) and globals (i.e. global components), threads
  # and systems. It is the main access point for the entire ECS.
  class Engine

    def initialize
      @threads = Hash.new
      @entities = Hash.new
      @globals = Hash.new
      @node_lists = Hash.new
    end

    # The nodes present in the engine. This list is updated automatically as
    # entities and components are added or removed.
    def nodes
      EMS.nodes
    end

    # Adds `entity' to this engine, updating the node lists accordingly.
    def add_entity entity
      @entities[entity.id] = entity
      entity.engine = self
      @node_lists.each do |sym, node_list|
        node_list.push entity if entity.matches_node? sym
      end
    end

    # Removes an entity (given it's `id') from this engine, updating the node
    # lists accordingly.
    def remove_entity id
      entity = @entities.delete(id)
      entity.engine = nil
      @node_lists.each_value do |node_list|
        node_list.delete entity
      end
    end

    # Gets an entity from this engine based on its `id'. Returns nil if there is
    # no such entity within this engine (i.e. if `has_entity?' returns false).
    def get_entity id
      @entities[id]
    end

    # Returns true if there exists an entity with the given `id' within this engine,
    # false otherwise.
    def has_entity? id
      @entities.has_key? id
    end

    # Called by an entity when a component is added to it.
    # Used internally.
    def component_added entity, component
      @node_lists.each do |sym, node_list|
        add_if_match entity, sym, node_list if nodes[sym].include? component
      end
    end

    # Called by an entity when a component is removed from it.
    # USed internally.
    def component_removed entity, component
      @node_lists.each do |sym, node_list|
        if nodes[sym].include? component and node_list.include? entity
          node_list.delete entity unless entity.matches_node? sym
        end
      end
    end

    # Sets a global component. It will be identified by its class name.
    # e.g. If the component's class name is FooBar, it will be identified
    # with the symbol :foo_bar
    def set_global component
      @globals[component.class.name.underscore.to_sym] = component
    end

    # Unsets the global identified by `sym'.
    def unset_global sym
      @globals.delete sym
    end

    # Retrieves the global identified by `sym'.
    def get_global sym
      @globals[sym]
    end

    # Return true if there exists a global identified by `sym' in this engine,
    # false otherwise.
    def has_global? sym
      @globals.has_key? sym
    end

    # Retrieved the node list containing all nodes of the type `sym'.
    def get_node_list sym
      node_list = @node_lists[sym]
      if node_list.nil?
        node_list = Array.new
        @entities.each_value do |entity|
          add_if_match entity, sym, node_list
        end
        @node_lists[sym] = node_list
      end
      node_list
    end

    # Adds the `thread' to this engine.
    def add_thread thread
      @threads[thread.id] = thread
    end

    # Removes the thread identified by `id' from this engine.
    def remove_thread id
      @threads.delete id
    end

    # Retrieves the thread identified by `id' from this engine.
    def get_thread id
      @threads[id]
    end

    # Returns true if there exists a thread identified by `id' within this
    # engine, false otherwise.
    def has_thread? id
      @threads.has_key? id
    end

    # Updates this engine, or more precisely, triggers an update on all threads
    # within this engine.
    def update
      @threads.each_value do |s|
        s.update self
      end
    end

    # Shuts the engine dow. This will cause all threads contained within this engine
    # to shut down, and then removes all threads from this engine.
    def shut_down
      @threads.each_value do |s|
        s.shut_down
      end
      @threads.clear
    end

  end
end
