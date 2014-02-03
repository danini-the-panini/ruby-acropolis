module EMS
  def self.nodes
    @nodes ||= Hash.new
  end

  def NANOS_PER_SECOND
    1000000000
  end
end
