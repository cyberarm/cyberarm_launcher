module CyberarmLauncher
  class Application
    attr_reader :readme, :repo_data
    def initialize(application_file)
      @data = YAML.load_file(application_file)
      @valid = false
      @readme = {}
      @repo_data = {}

      validate!

      # TODO: Do this better
      if valid?
        @data["application"].each do |key, value|
          define_singleton_method(key.to_sym) do
            value
          end
        end

        populate_repo_data
        populate_readme_data
      else
        pp @data
      end
    end

    def validate!
      @valid = assert_has_nonblank("application") &&
               assert_has_nonblank("application", "id") &&
               assert_has_nonblank("application", "type") &&
               assert_has_nonblank("application", "name") &&
               assert_has_nonblank("application", "repo") &&
               assert_has_nonblank("application", "provider") &&
               assert_has_nonblank("application", "uses_core") &&
               assert_has_nonblank("application", "platform")
    end

    def assert_has_nonblank(*keys)
      @data.dig(*keys) != nil && @data.dig(*keys).to_s.length > 0
    end

    def valid?
      @valid
    end

    def repo_size
      if repo_data[:size] < 1_000
        "#{repo_data[:size]} KB"
      elsif repo_data[:size] < 100_000
        "#{(repo_data[:size] / 1_000.0).round(2)} MB"
      end
    end

    def populate_readme_data
      data = ""
      if Cache.expired?(@data["application"]["id"], "provider_api", "readme.json")
        # Assuming github
        @request = Excon.get("https://api.github.com/repos/#{@data["application"]["repo"]}/readme")

        if @request.status.between?(200, 299)
          Cache.store(@data["application"]["id"], "provider_api", "readme.json", @request.body)

          data = @request.body
        elsif @request.status == 404
          log.warn "#{@data["application"]["name"]} has no README available!"
          data = "{\"content\":\"\"}"
        else
          raise "ERROR: #{@request.status}"
        end
      else
        data = Cache.retrieve(@data["application"]["id"], "provider_api", "readme.json")
      end

      data = JSON.parse(data, symbolize_names: true)
      _readme = Base64.decode64(data[:content])

      i = 0
      _readme.each_line do |line|
        @readme[i] = line

        i += 1
      end
    end

    def populate_repo_data
      data = ""
      if Cache.expired?(@data["application"]["id"], "provider_api", "repo.json")
        # Assuming github
        @request = Excon.get("https://api.github.com/repos/#{@data["application"]["repo"]}")

        if @request.status.between?(200, 299)
          Cache.store(@data["application"]["id"], "provider_api", "repo.json", @request.body)
          data = @request.body
        end
      else
        data = Cache.retrieve(@data["application"]["id"], "provider_api", "repo.json")
      end

      @repo_data = JSON.parse(data, symbolize_names: true)
    end
  end
end