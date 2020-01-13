module CyberarmLauncher
  class Backend
    attr_reader :applications, :downloads
    def initialize
      @applications = []
      @downloads = []
    end
  end
end