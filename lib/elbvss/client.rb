require 'aws-sdk'
require 'etcd'
require 'fleet'

require_relative 'instance'
require_relative 'instance_builder'
require_relative 'vulcand_backend'
require_relative 'vulcand_server'

module Elbvss
  class Client
    def initialize
      @ec2 = Aws::EC2::Client.new
      @elb = Aws::ElasticLoadBalancing::Client.new

      host, port = ENV['ETCD_API_URL'].split ':'
      @etcd = Etcd.client(host: host, port: port)

      Fleet.configure do |fleet|
        fleet.fleet_api_url = ENV['FLEET_API_URL']
      end
      @fleet = Fleet.new
    end

    def sync
      # instances = get_instances
      instances = dummy_instances
      delete_target_servers =
        get_delete_target_vulcand_servers(get_vulcand_backends, instances)
      delete_vulcand_servers delete_target_servers
      add_target_servers =
        get_add_target_vulcand_servers(get_vulcand_backends, instances)
      add_vulcand_servers add_target_servers
    end

    private

    def add_machine_id_to(instance_builders)
      machines = get_machines
      instance_builders.map do |i|
        machine = machines.find {|m| m[:ip] == i.ip_address }
        machine_id = machine ? machine[:id] : nil
        i.add_machine_id machine_id
      end
    end

    def add_ip_address_to(instance_builders)
      ip_addresses = get_ip_addresses instances
      instance_builders.map do |i|
        ip_info = ip_addresses.find {|x| x[:id] == i.instance_id }
        ip = ip_info ? ip_info[:ip] : nil
        i.add_ip_address ip
      end
    end

    def add_vulcand_servers(servers)
      servers.each do |s|
        @etcd.set s.key, value: s.value
      end
    end

    def delete_vulcand_servers(servers)
      servers.each do |s|
        @etcd.delete s.key
      end
    end

    def get_add_target_vulcand_servers(backends, instances)
      active_instances = instances.select(&:active?)
      backends.flat_map do |b|
        server_machine_ids = b.servers.map(&:machine_id)
        not_exists_active_instances_in_backend = active_instances.reject do |i|
          server_machine_ids.include? i.machine_id
        end
        not_exists_active_instances_in_backend.map do |i|
          VulcandServer.new(
            key: "/vulcand/backends/#{b.backend_id}/servers/#{i.machine_id}",
            value: JSON.generate({
              URL: "http://#{i.ip_address}:#{b.backend_id}"
            })
          )
        end
      end
    end

    def get_delete_target_vulcand_servers(backends, instances)
      active_machine_ids = instances.select(&:active?).map(&:machine_id)
      servers = backends.flat_map(&:servers)
      servers.reject {|s| active_machine_ids.include? s.machine_id }
    end

    def get_vulcand_backends
      options = { recursive: true }
      backends = @etcd.get('/vulcand/backends/', options).node.children
      backends.map {|b| VulcandBackend.from_etcd_backend b }
    end

    def get_instances
      instance_builders = get_instances_in_elb
      instance_builders = add_ip_address_to instance_builders
      instance_builders = add_machine_id_to instance_builders
      instance_builders.map(&:build)
    end

    def get_instances_in_elb(load_balancer_name = ENV['LOAD_BALANCER_NAME'])
      @elb.describe_instance_health(
        load_balancer_name: load_balancer_name
      ).flat_map do |res|
        res.data.instance_states.map do |instance|
          InstanceBuilder.new(
            instance_id: instance.instance_id,
            in_service: instance.state == 'InService'
          )
        end
      end
    end

    def get_ip_addresses(instances)
      return [] if instances.empty?

      @ec2.describe_instances(
        filters: [
          {
            name: 'instance-id',
            values: instances.map {|i| i.instance_id }
          }
        ]
      ).flat_map do |res|
        res.data.reservations.flat_map do |reservation|
          reservation.instances.map do |instance|
            {
              id: instance.instance_id,
              ip: instance.private_ip_address
            }
          end
        end
      end
    end

    def get_fleet_machines
      @fleet.list_machines['machines'].map do |m|
        {
          id: m['id'],
          ip: m['primaryIP']
        }
      end
    end

    def dummy_instances
      # TODO: delete
      [
        Instance.new(
          instance_id: 'foo',
          in_service: true,
          ip_address: '172.17.8.101',
          machine_id: 'foo'
        ),
        Instance.new(
          instance_id: 'dummy1',
          in_service: false,
          ip_address: '172.17.8.150',
          machine_id: 'dummy'
        ),
        Instance.new(
          instance_id: 'dummy2',
          in_service: true,
          ip_address: '172.17.8.151',
          machine_id: 'dummy2'
        )
      ]
    end
  end
end
