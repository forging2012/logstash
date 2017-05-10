# encoding: utf-8
require "logstash/namespace"
require "logstash/logging"
require "erb"

class LogStash::Modules
  include LogStash::Util::Loggable

  def initialize(name, directory)
    @name = name
    @directory = directory  
  end

  def template
    ::File.join(@directory, "logstash/module.erb")
  end

  def modulename
    @name
  end

  class ModuleConfig

    def initialize(template, settings)
      @template = template
      @settings = settings
    end

    def setting(value, default)
      @settings[value].nil? ? default : @settings[value]
    end

    def render
      # process the template and settings
      # send back as a string with no newlines (the '>' part)
      renderer = ERB.new(File.read(@template), 3, '>')
      renderer.result(binding)
    end
  end

  def config_string(settings = {})
    # settings should be the subset from the YAML file with a structure like
    # {"name" => "plugin name", "k1" => "v1", "k2" => "v2"}, etc.
    mc = ModuleConfig.new(template, settings)
    mc.render
  end

end # class LogStash::Modules

# LogStash::PLUGIN_REGISTRY.add(:modules, "example", LogStash::Modules.new("example", File.join(File.dirname(__FILE__), "..", "configuration"))