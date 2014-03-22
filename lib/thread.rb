require_relative 'ems'
require 'securerandom'

module EMS
  # Threads simply manage the timing of a collection of systems, ensuring that the correct
  # deltas are sent to each system, and controlling how often systems are updated.
  class Thread

    def initialize
      @id = SecureRandom::uuid
      @systems = Hash.new

      @delta = 0
      @time = 0
      @current_time = Time::timestamp
    end

    def id
      @id
    end

    # Default timing method: variable timing.
    def update engine
      new_time = Time::timestamp
      @delta = (new_time - @current_time) / EMS::NANOS_PER_SECOND
      @current_time = new_time
      @time += @delta

      @systems.each_value do |s|
        s.update self
      end
    end

    # Nothing to shut down.
    # TODO: maybe systems require shutting down?
    def shut_down
    end

    # Adds a system to this thread.
    def add_system system
      @systems[system.id] = system
    end

    # Removes a system from this thread.
    def remove_system id
      @systems.delete id
    end

    # Retrieves a system from this thread.
    def get_system id
      @systems[id]
    end

    # Returns true if the system exists within this thread, false otherwise.
    def has_system? id
      @systems.has_key? id
    end

  end
end
