require_relative 'helper'
require_relative 'ems'
require 'securerandom'

module EMS

  # This class encapsulates a list of components that define an entities state.
  # All objects within the Entity Component System are represented as entities.
  # A new entity is an empty ``box'' that can be filled with any kind of state-
  # keeping component.
  class Entity

    def initialize
      @id = SecureRandom::uuid
      @components = Hash.new
    end

    # The entity's unique ID.
    def id
      @id
    end

    # The list of nodes this entity belongs to.
    def nodes
      EMS.nodes
    end

    # Adds a component to this entity. The symbol used to identify the component
    # will be the component's class name.
    # e.g. If the component's class is FooBar, the symbol used to identify it
    # will be :foo_bar.
    def add_component component
      self[component.class.to_s.underscore.to_sym] = component
    end

    # Adds a component to this entity, identifying it with `sym'.
    def []= sym, component
      @components[sym] = component
      @engine.component_added self, sym unless @engine.nil?
    end

    # Removes the compnent ientified by `sym' from this entity.
    def remove_component sym
      component = @components.delete sym
      @engine.component_removed self, sym unless @engine.nil?
    end

    # Retrieves the component identified by `sym' from this entity.
    def [] sym
      @components[sym]
    end

    # Returns true if there exists a component within this entity that is
    # identified by `sym', false otherwise.
    def has_component? sym
      @components.has_key? sym
    end

    # Returns true if this entity's component list matches that of the node
    # identified by `sym', false otherwise.
    def matches_node? sym
      nodes[sym].each do |field|
        return false unless @components.has_key? field
      end
      true
    end

    # Used to assign the engine containing this entity. Used internally.
    def engine= engine
      @engine = engine
    end

  end
end
