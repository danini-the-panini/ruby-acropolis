require_relative 'helper'
require_relative 'ems'
require 'securerandom'

module EMS
  class Entity

    def initialize
      @id = SecureRandom::uuid
      @components = Hash.new
    end

    def id
      @id
    end

    def nodes
      EMS.nodes
    end

    def add_component component
      self[component.class.to_s.underscore.to_sym] = component
    end

    def []= sym, component
      @components[sym] = component
      @engine.component_added self, sym unless @engine.nil?
    end

    def remove_component sym
      component = @components.delete sym
      @engine.component_removed self, sym unless @engine.nil?
    end

    def [] sym
      @components[sym]
    end

    def has_component? sym
      @components.has_key? sym
    end

    def matches_node? sym
      nodes[sym].each do |field|
        return false unless @components.has_key? field
      end
      true
    end

    def engine= engine
      @engine = engine
    end

  end
end
