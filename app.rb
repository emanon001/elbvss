require './init'
require 'logger'

interval = (ENV['SYNC_INTERVAL'] || 60).to_i
STDOUT.sync = true
logger = Logger.new(STDOUT)

loop do
  begin
    Elbvss.client.sync
  rescue => e
    logger.error e
  ensure
    sleep interval
  end
end
