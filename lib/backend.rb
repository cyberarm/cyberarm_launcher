module CyberarmLauncher
  class Backend
    attr_reader :applications, :downloaders, :installers, :controllers, :data
    def initialize
      @applications = []
      @downloaders = []
      @installers = []

      @controllers = {}

      @data = {}
    end

    def busy?
      !(@downloaders.size == 0 && @installers.size == 0)
    end

    def get_application(id)
      @applications.find { |a| a.id == id }
    end

    def create_downloader(id, url, data_type, filename)
      _downloader = get_downloader(id)
      return _downloader if _downloader

      _downloader =  Downloader.new(id, url, data_type, filename)
      @downloaders.push(_downloader)

      return _downloader
    end

    def get_downloader(id)
      @downloaders.find { |d| d.id == id }
    end

    def create_installer(id, data_type, filename)
      _installer = get_installer(id)
      return _installer if _installer

      _installer = Installer.new(id, data_type, filename)
      @installers.push(_installer)

      return _installer
    end

    def get_installer(id)
      @installers.find { |d| d.id == id }
    end

    def create_controller(app_id, downloader, installer = nil)
      _controller = get_controller(app_id)
      return _controller if _controller

      _controller = Controller.new(downloader, installer)
      @controllers[app_id] = _controller

      return _controller
    end

    def get_controller(app_id)
      @controllers.dig(app_id)
    end
  end
end