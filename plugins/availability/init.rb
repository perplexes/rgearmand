require 'availability'

Rgearmand.options do |opts|
  OPTIONS[:puppetmaster] = nil
  opts.on("-m", "--master NODENAME:IP:PORT", "Master node (initially) to notify we're online") do |master|
    OPTIONS[:puppetmaster] = master
  end
end

Rgearmand.after_init do
  @hearbeat = Rgearmand::Availability.new
  
  if OPTIONS[:puppetmaster]
    (nodename, ip, port) = OPTIONS[:puppetmaster].split(":")
    @hearbeat.add_neighbor(nodename, :ip => ip, :port => port)
  end
  
  EventMachine::PeriodicTimer.new(5) do
    @hearbeat.emit_heartbeat
  end
end
