module CyberarmLauncher
  class BootState < CyberarmEngine::GameState
    def setup
      application_specs = Dir.glob("#{APPLICATIONS_PATH}/*.yml")

      @logo = Gosu::Image.new("#{ASSETS_PATH}/avatar.png")
      @font = Gosu::Font.new(72, name: "Impact", bold: true) # "Droid Sans"
      @small_font = Gosu::Font.new(28, name: "Bitstream Vera Sans Mono")

      @text = NAME.upcase
      @version_text = "v#{VERSION}"
      @tagline_text = "#{@version_text} — Supports #{application_specs.size} apps and games"
      @text_width = @font.text_width(@text)
      @text_width = @font.text_width(@text)

      @x = window.width / 2
      @y = window.height / 2

      @padding = 20
      @width = @logo.width + @padding + @text_width

      @logo_position = @x - @width / 2 + @logo.width / 2
      @text_position = @x - @width / 2 + @logo.width + @padding

      @timer = CyberarmEngine::Timer.new(750) do
        push_state(IntroState)
      end

      window.add_worker(100) do |worker|
        if worker.life_time >= 100
          application_specs.each do |file|
            app = Application.new(file)

            if app.valid?
              worker.backend.applications.each do |a|
                if a.id == app.id
                  raise "\"#{app.name}\" can't share an id with \"#{a.name}\"!"
                end
              end

              # This is used by MainMenu to decide whether to update app's installation information
              worker.backend.data[app.id] = {}
              worker.backend.data[app.id][:status] = :none

              worker.backend.applications << app
            end
          end

          worker.done!
        end
      end
    end

    def draw
      super
      stylistic_background(width: 32, height: 32, initial_color: Gosu::Color.rgb(127, 64, 0))

      @logo.draw_rot(@logo_position, @y, 0, 14)
      @font.draw_text(@text, @text_position, @y - @font.height / 2, 0)
      @small_font.draw_text(@tagline_text, @x, @y + @font.height / 2, 0)
    end

    def update
      super

      @timer.update
    end

    def stylistic_background(width:, height:, initial_color: Gosu::Color.rgb(175, 200, 147))
      (window.width.to_f / width).ceil.times do |x|
        (window.height.to_f / height).ceil.times do |y|
          Gosu.draw_rect(x * width, y * height, width, height, sample_color(initial_color, x + y))
        end
      end
    end

    def sample_color(color, index)
      Gosu::Color.rgb(
        (color.red + index % 255),
        (color.green + index % 255),
        (color.blue + index % 255)
      )
    end
  end
end