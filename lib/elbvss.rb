require 'elbvss/client'

module Elbvss
  def self.client
    Elbvss::Client.new
  end
end