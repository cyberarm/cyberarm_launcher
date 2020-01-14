module CyberarmLauncher
  class Backend
    attr_reader :applications, :downloads
    def initialize
      @applications = []
      @downloads = []
    end

    def create_downloader(id, url, data_type, filename)
      _downloader = @downloads.find { |d| d.id == id }
      return _downloader if _downloader

      _downloader =  Downloader.new(id, url, data_type, filename)
      @downloads.push(_downloader)
      Thread.new { _downloader.start }

      return _downloader
    end

    def get_downloader(id)
      @downloads.find { |d| d.id == id }
    end
  end
end