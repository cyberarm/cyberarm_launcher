module CyberarmLauncher
  class Installer
    attr_reader :id, :status
    def initialize(id, data_type, filename)
      @id = id
      @data_type = data_type
      @filename = filename


      @status = "Pending..."

      @failed = false

      log.info "Created Installer for: #{id}, data type: #{data_type}, filename: #{filename}"

      @progress = 0
      @installation_steps = 3

      @install_path = "#{INSTALLATION_PATH}/#{@id}"
    end

    def start
      install!
    end

    def progress
      @progress.to_f / @installation_steps
    end

    def cancel
    end

    def install!
      # unzip archive
      @status = "Extracting archive..."
      extract_archive!
      @progress += 1

      # install dependencies
      @status = "Installing dependencies..."
      install_dependencies!
      @progress += 1


      # on success, add application to list of installed apps
      unless @failed
        installed!

        @progress += 1
        @status = "Installation complete."
        log.info "Installation for: #{@id} completed successfully!"
      else
        @status = "Something went wrong."
        log.info "Installation for: #{@id} failed!"
      end

      # remove self from backend.installers
      $window.backend.installers.delete_if { |i| i.id == @id }
    end

    def extract_archive!
      Zip::File.open(Cache.path(@id, @data_type, @filename)) do |zip_file|
        zip_file.each do |entry|
          entry_name = entry.name.split("/")
          entry_name.delete(entry_name.first)
          entry_name = entry_name.join("/")

          if entry.file?
            File.write("#{@install_path}/#{entry_name}", entry.get_input_stream.read)

          elsif entry.directory?
            Cache.allocate_missing_folders("#{@install_path}/#{entry_name}")

          elsif entry.symlink?
            puts "Got a symlink!"
          else
            log.warn "Installer for #{@id}, got unknown entry in archive for {entry.name}"
          end
        end
      end
    end

    def install_dependencies!
      if File.exist?("#{@install_path}/#{$window.backend.get_application(@id).repo.split("/").last}.rb")
        puts "Yes."

        Dir.chdir(@install_path) do
          Bundler.with_clean_env do
            system("bundle package --all")
          end
        end
      end

      sleep 1
    end

    def installed!
      if File.exist?("#{@install_path}/#{$window.backend.get_application(@id).repo.split("/").last}.rb")
        Dir.chdir(@install_path) do
          Bundler.with_clean_env do
            system("bundle exec ruby #{@install_path}/#{$window.backend.get_application(@id).repo.split("/").last}.rb")
          end
        end
      end

      sleep 1.0
    end

    def failed?
      @failed
    end

    # TODO: cleanup when installation fails or is cancelled
    def failure_cleanup
    end
  end
end