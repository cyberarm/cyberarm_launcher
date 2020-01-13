module CyberarmLauncher
  class Downloader
    def initialize(url, streams = 1, priority = :normal)
      @url = url
      @streams = []
      @priority = priority

      # TODO: Support multiple download streams
      # using: https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests
      1.times do |i|
        @streams << allocate_stream(url)
      end

      @state = :pending
    end

    def allocate_stream(url, range = -1)
      Stream.new(url, range)
    end

    def progress
      progress = 0.0
      @streams.each { |stream| stream.progress + progress }

      progress /= @streams.size
    end

    def pause
      @streams.each(&:pause)
    end

    def resume
      @streams.each(&:resume)
    end
  end
end