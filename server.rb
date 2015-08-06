require 'webrick'
require 'logger'

logfile = File.join(Dir.pwd, 'log', "#{Time.now.strftime('%Y-%m-%d')}.log")
$log = Logger.new(logfile)

server = WEBrick::HTTPServer.new(Port: 3002)
server.mount_proc '/s/' do |req, res|
  begin
    host = req.header['host'][0]
    ua = req.header['user-agent']
    full_path = "#{req.path}?#{req.query_string}"
    if ua =~ /spider/i
      res.status = 403
    else
      $log.info("#{host}, #{ua}, [#{full_path}], #{Time.now.to_i}")
      res.status = 404
      res['Content-Type'] = 'image/png'
    end
    res.body = '\r\n'
  rescue
    $log.info("ERROR: #{Time.now.to_i}")
  end
end

trap 'INT' do
  server.shutdown
end

WEBrick::Daemon.start
server.start
