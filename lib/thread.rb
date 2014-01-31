require_relative 'ems'
require 'securerandom'

module EMS
  class Thread

    def initialize
      @id = SecureRandom::uuid
      @systems = Hash.new
    end

    def id
      @id
    end

    def update engine
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
