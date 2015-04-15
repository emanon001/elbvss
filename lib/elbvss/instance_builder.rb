require_relative 'instance'

module Elbvss
  class InstanceBuilder
    attr_reader :instance_id, :in_service, :ip_address, :machine_id

    def initialize(instance_id: nil, in_service: nil)
      @instance_id = instance_id
      @in_service = in_service
    end

    def add_ip_address(ip_address)
      @ip_address = ip_address
      self
    end

    def add_machine_id(machine_id)
      @machine_id = machine_id
      self
    end

    def build
      fail unless @instance_id || @in_service.nil?

      Instance.new(
        instance_id: @instance_id,
        in_service: @in_service,
        ip_address: @ip_address,
        machine_id: @machine_id
      )
    end
  end
end
