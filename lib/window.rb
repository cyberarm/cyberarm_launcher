module CyberarmLauncher
  class Window < CyberarmEngine::Engine

    attr_reader :backend
    def initialize
      super(width: Gosu.screen_width / 4 * 3, height: Gosu.screen_height / 4 * 3, fullscreen: false)
      self.caption = CyberarmLauncher::NAME
      @workers = []
      @backend = Backend.new

      push_state(BootState)
    end

    def add_worker(frequency = 0, &block)
      @workers << Worker.new(@backend, frequency, &block)
    end

    def update
      super

      @workers.each(&:update)
      @workers.delete_if { |worker| worker.done? }
    end
  end
end