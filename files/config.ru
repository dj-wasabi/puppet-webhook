require './webhook'

#set :environment, :production

log = File.new("log/sinatra.log", "a")
log.sync = true
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application

