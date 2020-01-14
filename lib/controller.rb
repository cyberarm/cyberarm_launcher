module CyberarmLauncher
  class Controller
    def initialize(downloader, installer = nil)
      @downloader = downloader
      @installer = installer


      @action = @downloader
      @failed = false
      @done = false

      Thread.new do
        download

        unless failed?
          if installer
            install

            unless failed?
              done!
            else
              failed!
            end

          else
            done!
          end

        else
          failed!
        end
      end
    end

    def download
      $window.backend.data[@downloader.id][:status] = :downloading
      @action = @downloader
      @action.start
    end

    def install
      $window.backend.data[@downloader.id][:status] = :installing
      @action = @installer
      @action.start
    end

    def downloading?
      !@downloader.done?
    end

    def installing?
      @installer && !@installer.done?
    end

    def failed?
      @failed
    end

    def failed!
      if downloading?
        $window.backend.data[@downloader.id][:status] = :download_failed
      elsif installing?
        $window.backend.data[@downloader.id][:status] = :installation_failed
      end
    end

    def done?
      @done
    end

    def done!
      @done = true
      $window.backend.controllers[@app_id] = nil
    end

    def status
      @action.status
    end

    def progress
      @action.progress
    end

    def cancel
      @action.progress
    end
  end
end