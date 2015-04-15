module Elbvss
  class VulcandServer
    attr_reader :key, :machine_id, :value

    def initialize(key: nil, value: nil)
      fail unless key || value

      @key = key
      @value = value
      @machine_id = key.match(%r{([^/]+)$})[1]
    end
  end
end
