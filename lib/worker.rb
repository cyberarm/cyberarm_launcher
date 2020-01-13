module CyberarmLauncher
  class Worker
    attr_reader :backend, :freqency
    def initialize(backend, freqency, &block)
      @backend = backend
      @freqency = freqency

      @block = block

      @last_run = 0
      @done = false
    end

    def update
      if Gosu.milliseconds - @last_run >= @freqency
        @last_run = Gosu.milliseconds

        @block.call(self)

        @done = true if @freqency == 0
      end
    end

    def done?
      @done
    end
  end
end