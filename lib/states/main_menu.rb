module CyberarmLauncher
  class MainMenuState < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true
      background Gosu::Color.rgb(127, 64, 0)
      @font_size = 28
      @header_size = 72
      @caption_size = 32

      @sidebar_border_color = Gosu::Color.rgb(0, 0, 0)

      # HEADER
      stack(width: 1.0) do
        flow(width: 1.0) do
          button("Games", width: 0.325)
          button("Tools", width: 0.325)
          button("Settings", width: 0.325)
        end
      end

      # CONTAINER
      stack(height: 1.0, width: 1.0, margin_top: 5) do
        flow(width: 1.0, height: 1.0) do
          # SIDEBAR
          @sidebar = stack(width: 0.24, height: 1.0, margin_right: 2, padding: 10, border_color: [@sidebar_border_color, @sidebar_border_color, 0, 0], border_thickness: 2) do
            button("Home", width: 1.0) do
              page_home
            end

            label ""
            label "Games", font_size: @caption_size

            window.backend.applications.sort_by {|a| a.name }.each do |application|
              button(application.name, width: 1.0) do
                page_application(application)
              end
            end
          end

          # CONTENT
          @content = stack(width: 0.74, height: 1.0, padding: 10) do
            background 0xff552200
          end
        end
      end

      page_home
    end

    def page_home
      @content.clear do |element|
        element.image("#{ASSETS_PATH}/avatar.png", margin_bottom: 10)
        element.label(NAME.upcase, text_size: @header_size, font: "Impact")
        element.label(DESCRIPTION, text_size: @font_size, font: "Consolas")
      end
    end

    def page_application(app)
      @content.clear do |element|
        element.label "#{app.name}", text_size: 72
        element.label ""

        # TODO: Add support for adding Containers in clears
        # element.flow do
          element.button "Install"
          element.label " - N MB"
        # end

        app.readme.each do |id, el|
          if el.is_a?(String)
            element.label el
          elsif el.is_a?(Gosu::Image)
            element.image el
          end
        end
      end
    end
  end
end