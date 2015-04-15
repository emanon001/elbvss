require './init'

interval = (ENV['SYNC_INTERVAL'] || 60).to_i

loop do
  begin
    Elbvss.client.sync
  rescue => e
    p e
  ensure
    sleep interval
  end
end
