module CyberarmLauncher
  class Downloader
    attr_reader :id, :url
    def initialize(id, url, data_type, filename)
      @id = id
      @url = url
      @data_type = data_type
      @filename = filename

      @chunks = []
    end

    def start
      streamer = lambda do |chunk, remaining_bytes, total_bytes|
        @chunks << chunk
      end

      @downloader = Excon.get(url, :response_block => streamer, :middlewares  => Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower])

      Cache.store(@id, @data_type, @filename, @chunks.join)

      done!
    end

    def progress
      if app = $window.backend.applications.find { |a| a.id == @id }
        # Rough estimate as codeload.github.com doesn't provide a Content-Length header :(
        @chunks.join.length.to_f / (app.repo_data[:size] * 1_000)
      else
        0.0
      end
    end

    def pause
    end

    def resume
    end

    def cancel
      done!
    end

    def done!
      $window.backend.downloads.delete_if { |d| d == self }
    end
  end
end