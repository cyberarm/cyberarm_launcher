$logger = Logger.new(STDOUT)

def log
  $logger
end


Dir.glob("*/**/**.rb").each do |file|
  require_relative file.sub("lib/", "")
end

CyberarmLauncher::ROOT_PATH = File.expand_path("../../", __FILE__)
CyberarmLauncher::ASSETS_PATH = File.expand_path("../../assets", __FILE__)
CyberarmLauncher::APPLICATIONS_PATH = File.expand_path("../../applications", __FILE__)
CyberarmLauncher::CACHE_PATH = File.expand_path("../../data/.cache", __FILE__)