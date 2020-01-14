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
      @current_app = nil

      @current_app_installation_info = nil
      @current_app_installation_info_progress = nil
      @current_app_installation_info_status = nil

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

      window.add_worker(30) do |worker|
        worker.data[:active_app_id] ||= nil
        worker.data[:active_app_status] ||= nil

        if @current_app && worker.data.dig(:active_app_id) && worker.data.dig(:active_app_status) != current_app_status
          worker.data[:active_app_status] = current_app_status

          @current_app_installation_info.clear do
            app_installation_state(@current_app)
          end
        elsif @current_app && worker.data.dig(:active_app_id) != @current_app.id
          worker.data[:active_app_id] = @current_app.id

          @current_app_installation_info.clear do
            app_installation_state(@current_app)
          end
        end

        if app = @current_app # @current_app not nil? then set app equal to current app
          if app.installed?

          elsif app_installing?(app.id) && controller = app_controller(app.id)
            if @current_app_installation_info_status
              @current_app_installation_info_status.value = controller.status
              @current_app_installation_info_progress.value = controller.progress
            end

          elsif app_downloading?(app.id) && controller = app_controller(app.id)
            if @current_app_installation_info_progress
              @current_app_installation_info_progress.value = controller.progress
            end
          end
        end
      end
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
            @current_app = application
            page_application
          end
        end
      end
    end

    def page_home
      @current_app = nil
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

    def page_application(app = @current_app)
      @content.clear do
        label "#{app.name}", text_size: @header_size
        label "#{app.repo_data[:description]}", text_size: @caption_size

        label("#{app.type.capitalize} last updated: #{Time.parse(app.repo_data[:pushed_at]).strftime("%B %e, %Y")}", text_size: @footer_size)
        label ""
        if app.platform == "all" or OS.host_os.include?(app.platform)
          @current_app_installation_info = flow do
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

      app_installation_state(app)
    end

    def app_installation_state(app, container = @current_app_installation_info)
      if app.installed?
        button "Play"
        button "Uninstall"

      elsif app_installing?(app.id)
        button "Cancel" do
          if _installer = app_installing?(app.id)
            _installer.cancel
          end
        end
        @current_app_installation_info_progress = progress
        label "<c=f50>Installing:</c> "
        @current_app_installation_info_status = label ""


      elsif app_downloading?(app.id)
        button "Cancel"
        @current_app_installation_info_progress = progress
        label "#{app.repo_size} - Uses #{app.uses_core.split("_").join("+")} core", margin_left: 4

      elsif false#app_downloaded?(app.id)
        button "Install" do
        end

      else
        button "Download and Install" do
          _downloader = window.backend.create_downloader(app.id, app.package_url, "archive", "master.zip")
          _installer = window.backend.create_installer(app.id, "archive", "master.zip")

          window.backend.create_controller(app.id, _downloader, _installer)
        end

        label "#{app.repo_size} - Uses #{app.uses_core.split("_").join("+")} core", margin_left: 4
      end
    end

    def app_installing?(id)
      window.backend.data.dig(id, :status) == :installing
    end

    def app_downloading?(id)
      window.backend.data.dig(id, :status) == :downloading
    end

    def app_controller(id)
      window.backend.get_controller(id)
    end

    def current_app_status
      if @current_app
        window.backend.data.dig(@current_app.id, :status)
      else
        :none
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