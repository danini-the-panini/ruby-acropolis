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
  class Engine

    def initialize
      @threads = Hash.new
      @entities = Hash.new
      @globals = Hash.new
      @node_lists = Hash.new
    end

    def nodes
      EMS.nodes
    end

    def add_if_match entity, node, node_list
      node_list.push entity if entity.matches_node? node
    end

    def add_entity entity
      @entities[entity.id] = entity
      entity.engine = self
      @node_lists.each do |sym, node_list|
        add_if_match entity, sym, node_list
      end
    end

    def remove_entity id
      entity = @entities.delete(id)
      entity.engine = nil
      @node_lists.each_value do |node_list|
        node_list.delete entity
      end
    end

    def get_entity id
      @entities[id]
    end

    def has_entity? id
      @entities.has_key? id
    end

    def component_added entity, component
      @node_lists.each do |sym, node_list|
        add_if_match entity, sym, node_list if nodes[sym].include? component
      end
    end

    def component_removed entity, component
      @node_lists.each do |sym, node_list|
        if nodes[sym].include? component and node_list.include? entity
          node_list.delete entity unless entity.matches_node? sym
        end
      end
    end

    def set_global component
      @globals[component.class.name.underscore.to_sym] = component
    end

    def unset_global sym
      @globals.delete sym
    end

    def get_global sym
      @globals[sym]
    end

    def has_global? sym
      @globals.has_key? sym
    end

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

    def add_thread thread
      @threads[thread.id] = thread
    end

    def remove_thread id
      @threads.delete id
    end

    def get_thread id
      @threads[id]
    end

    def has_thread? id
      @threads.has_key? id
    end

    def update
      @threads.each_value do |s|
        s.update self
      end
    end

    def shut_down
      @threads.each_value do |s|
        s.shut_down
      end
      @threads.clear
    end

    private :add_if_match

  end
end
