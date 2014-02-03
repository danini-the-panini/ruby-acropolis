require_relative 'ems'
require 'securerandom'

module EMS
  class System

    def initialize
      @id = SecureRandom::uuid
    end

    def id
      @id
    end

    def update engine, time, dt
    end

  end
end
