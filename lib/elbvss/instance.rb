module Elbvss
  class Instance
    attr_reader :instance_id, :ip_address, :machine_id

    def initialize(instance_id: nil, in_service: nil, ip_address: nil, machine_id: nil)
      fail unless instance_id || in_service

      @instance_id = instance_id
      @in_service = in_service
      @ip_address = ip_address
      @machine_id = machine_id
    end

    def in_service?
      @in_service
    end

    def active?
      in_service? && @ip_address && @machine_id
    end

    def inactive?
      !active?
    end
  end
end
