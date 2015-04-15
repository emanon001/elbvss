require_relative 'vulcand_server'

module Elbvss
  class VulcandBackend
    attr_reader :key, :servers, :backend_id

    def initialize(key: nil, servers: nil)
      fail unless key || servers

      @key = key
      @servers = servers
      @backend_id = key.match(%r{([^/]+)$})[1]
    end

    def self.from_etcd_backend(backend)
      server = backend.children.find {|c| c.key.end_with? '/servers' }
      fail unless server

      servers = server.children.map do |s|
        VulcandServer.new(
          key: s.key,
          value: s.value
        )
      end

      VulcandBackend.new(
        key: backend.key,
        servers: servers
      )
    end
  end
end
