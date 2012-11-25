module NitPicker
  class Collector
    attr_accessor :name, :type, :config

    def initialize(name)
      @name = name
    end

    def configure(config)
      @config = config
    end
  end
end
