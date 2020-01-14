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
          @sidebar = stack(width: 0.24, height: 1.0, margin_right: 2, padding: 10, border_color: [@sidebar_border_color, @sidebar_border_color, 0, 0], border_thickness: 2) do
          end

          # CONTENT
          @content = stack(width: 0.74, height: 1.0, padding: 10) do
            background 0xff552200
          end
        end
      end

      refresh_sidebar
      page_home
    end

    def refresh_sidebar
      @sidebar.clear do
        button("Home", width: 1.0) do
          page_home
        end

        label ""
        label "#{@show_only.capitalize}s", text_size: @caption_size

        window.backend.applications.reject { |a| a.type != @show_only }.sort_by {|a| a.name }.each do |application|
          button(application.name, width: 1.0) do
            page_application(application)
          end
        end
      end
    end

    def page_home
      @content.clear do
        flow do
          image("#{ASSETS_PATH}/avatar.png", margin_bottom: 10)
          stack(margin_left: 10) do |se|
            label(NAME.upcase, text_size: @header_size, font: "Impact")
            label(DESCRIPTION, text_size: @font_size, font: "Consolas")
          end
        end
      end
    end

    def page_application(app)
      @content.clear do
        label "#{app.name}", text_size: @header_size
        label "#{app.repo_data[:description]}", text_size: @caption_size

        label("#{app.type.capitalize} last updated: #{Time.parse(app.repo_data[:pushed_at]).strftime("%B %e, %Y")}", text_size: @footer_size)
        label ""
        if app.platform == "all" or OS.host_os.include?(app.platform)
          # TODO: Add support for adding Containers in clears
          flow do |_flow|
            button "Install" do
              _flow.clear do
                _downloader = window.backend.create_downloader(app.id, app.package_url, "archive", "master.zip")
                _progress = progress

                window.add_worker(50) do |worker|
                  unless window.backend.get_downloader(_downloader.id)
                    worker.done!
                    _flow.clear do
                      label "<c=ff0>Installing...</c>"
                      window.add_worker do |installer|
                      end
                    end

                  else
                    _progress.value = _downloader.progress
                  end
                end

                button "Cancel" do
                  puts "TODO"
                end
              end
            end

            label "#{app.repo_size} - Uses #{app.uses_core.split("_").join("+")} core", margin_left: 4
          end

          label "Note: Size shown is size of repo, download may be smaller.", text_size: @footer_size
        end


        if app.platform != "all" and not OS.host_os.include?(app.platform)
          label "<c=f30>Compatible with #{app.platform.capitalize} only</c>"
        end
        label ""

        app.readme.each do |id, el|
          if el.is_a?(String)
            label(format_simplified_markdown(el))
          elsif el.is_a?(Gosu::Image)
            image el
          end
        end
      end
    end

    def format_simplified_markdown(string)
      if string.start_with?("#")
        _string = string.gsub("#", "")

        "<b>#{_string.strip}</b>"

      else
        string.strip
      end
    end
  end
end