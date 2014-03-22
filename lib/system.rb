require_relative 'ems'
require 'securerandom'

module EMS
  # `Systems' are where the real work happens. They encapsulate the logic of
  # the overall ECS. Systems generally update the state of entities matching
  # a particular node.
  # TODO: provide example maybe?
  class System

    def initialize
      @id = SecureRandom::uuid
    end

    # The unique ID of the system.
    def id
      @id
    end

    # Default update method does nothing
    def update engine, time, dt
    end

  end
end
