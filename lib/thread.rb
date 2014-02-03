require_relative 'ems'
require 'securerandom'

module EMS
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

    def update engine
      new_time = Time::timestamp
      @delta = (new_time - @current_time) / EMS::NANOS_PER_SECOND
      @current_time = new_time
      @time += @delta

      @systems.each_value do |s|
        s.update self
      end
    end

    def shut_down
    end

    def add_system system
      @systems[system.id] = system
    end

    def remove_system id
      @systems.delete id
    end

    def get_system id
      @systems[id]
    end

    def has_system? id
      @systems.has_key? id
    end

  end
end
