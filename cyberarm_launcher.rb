if ARGV.join.include?("uid")
  require "securerandom"

  puts SecureRandom.uuid
  exit
end

require "bundler"
Bundler.setup(:default)

require "excon"
require "socket"
require "yaml"
require "json"
require "base64"
require "logger"

begin
  require_relative "../"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/bootstrap"

CyberarmLauncher::Window.new.show