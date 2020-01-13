module CyberarmLauncher
  class MainMenuState < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true
      background Gosu::Color.rgb(127, 64, 0)
      @footer_size = 22
      @font_size = 28
      @header_size = 72
      @caption_size = 32

      @sidebar_border_color = Gosu::Color.rgb(0, 0, 0)
      @show_only = "game"

      # HEADER
      stack(width: 1.0) do
        flow(width: 1.0) do
          button("Games", width: 0.325) do
            @show_only = "game"

            refresh_sidebar
          end

          button("Tools", width: 0.325) do
            @show_only = "tool"

            refresh_sidebar
          end

          button("Settings", width: 0.325)
        end
      end

      # CONTAINER
      stack(height: 1.0, width: 1.0, margin_top: 5) do
        flow(width: 1.0, height: 1.0) do
          # SIDEBAR
          @sidebar = stack(width: 0.24, height: 1.0, margin_right: 2, padding: 10, border_color: [@sidebar_border_color, @sidebar_border_color, 0, 0], border_thickness: 2) do |element|
            refresh_sidebar(element)
          end

          # CONTENT
          @content = stack(width: 0.74, height: 1.0, padding: 10) do
            background 0xff552200
          end
        end
      end

      page_home
    end

    def refresh_sidebar(element = @sidebar)
      element.clear do |bar|
        element.button("Home", width: 1.0) do
          page_home
        end

        element.label ""
        element.label "#{@show_only.capitalize}s", text_size: @caption_size

        window.backend.applications.reject { |a| a.type != @show_only }.sort_by {|a| a.name }.each do |application|
          element.button(application.name, width: 1.0) do
            page_application(application)
          end
        end
      end
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
        element.label "#{app.name}", text_size: @header_size
        element.label "#{app.repo_data[:description]}", text_size: @caption_size

        element.label("#{app.type.capitalize} last updated: #{Time.parse(app.repo_data[:pushed_at]).strftime("%B %e, %Y")}", text_size: @footer_size)
        element.label ""
        if app.platform == "all" or OS.host_os.include?(app.platform)
          # TODO: Add support for adding Containers in clears
          # element.flow do
          element.button "Install"
          element.label " - N MB - Uses #{app.uses_core.split("_").join("+")} core"
          # end
        end

        if app.platform != "all" and not OS.host_os.include?(app.platform)
          element.label "<c=f30>Compatible with #{app.platform.capitalize} only</c>"
        end
        element.label ""

        app.readme.each do |id, el|
          if el.is_a?(String)
            element.label(format_simplified_markdown(el))
          elsif el.is_a?(Gosu::Image)
            element.image el
          end
        end
      end
    end

    def format_simplified_markdown(string)
      if string.start_with?("#")
        string.gsub!("#", "")

        "<b>#{string.strip}</b>"

      else
        string.strip
      end
    end
  end
end