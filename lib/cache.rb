module CyberarmLauncher
  class Cache
    def self.store(application_id, data_type, name, data)
      path = "#{CACHE_PATH}/#{application_id}/#{data_type}"

      allocate_missing_folders(path)
      File.write("#{path}/#{name}", data)
    end

    def self.retrieve(application_id, data_type, name)
      path = "#{CACHE_PATH}/#{application_id}/#{data_type}"

      if File.exist?("#{path}/#{name}")
        File.read("#{path}/#{name}")
      else
        return nil
      end
    end

    def self.expired?(application_id, data_type, name, max_age = 60*60) # seconds
      path = "#{CACHE_PATH}/#{application_id}/#{data_type}"

      return true unless File.exist?("#{path}/#{name}")

      (Time.now - File.new("#{path}/#{name}").mtime) >= max_age
    end

    def self.allocate_missing_folders(path)
      local_path = path.sub("#{ROOT_PATH}/", "")
      last_folder = ""

      local_path.split("/").each do |folder|
        unless File.exist?("#{ROOT_PATH}#{last_folder}/#{folder}")
          log.info "Creating folder: #{ROOT_PATH}#{last_folder}/#{folder}"

          FileUtils.mkdir("#{ROOT_PATH}#{last_folder}/#{folder}")
        end

        last_folder = "#{last_folder}/#{folder}"
      end
    end
  end
end