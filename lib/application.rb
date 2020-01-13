module CyberarmLauncher
  class Application
    attr_reader :readme
    def initialize(application_file)
      @data = YAML.load_file(application_file)
      @valid = false
      @readme = {}

      validate!

      # TODO: Do this better
      if valid?
        @data["application"].each do |key, value|
          define_singleton_method(key.to_sym) do
            value
          end
        end

        populate_readme_data
      else
        pp @data
      end
    end

    def validate!
      @valid = assert_has_nonblank("application") &&
               assert_has_nonblank("application", "id") &&
               assert_has_nonblank("application", "name") &&
               assert_has_nonblank("application", "repo") &&
               assert_has_nonblank("application", "provider") &&
               assert_has_nonblank("application", "uses_core")
    end

    def assert_has_nonblank(*keys)
      @data.dig(*keys) != nil
    end

    def valid?
      @valid
    end

    def populate_readme_data
      data = ""
      if Cache.expired?(@data["application"]["id"], "provider_api", "readme.json")
        # Assuming github
        @request = Excon.get("https://api.github.com/repos/#{@data["application"]["repo"]}/readme")

        if @request.status.between?(200, 299)
          Cache.store(@data["application"]["id"], "provider_api", "readme.json", @request.body)
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
  end
end