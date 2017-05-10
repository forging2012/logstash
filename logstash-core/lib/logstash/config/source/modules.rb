# encoding: utf-8
require "logstash/config/source/base"
require "logstash/config/pipeline_config"
require "logstash/util/loggable"
require "logstash/errors"

module LogStash module Config module Source
  class Modules < Base
    include LogStash::Util::Loggable
    def pipeline_configs
      pipelines = []
      plugin_modules = LogStash::PLUGIN_REGISTRY.plugins_with_type(:modules)
      
      @settings.get("modules").each do |modulevars|
        begin
          thismodule = plugin_modules.find { |allmodules| allmodules.modulename == modulevars["name"] }
          altname = "module-#{modulevars["name"]}"
          pipeline_id = modulevars["pipeline_id"].nil? ? altname : modulevars["pipeline_id"]
          config_string = thismodule.config_string(modulevars)
          logger.error("CONFIG_STRING", :config_string => config_string)
          config_part = org.logstash.common.SourceWithMetadata.new("module", altname, config_string)
          pipelines << PipelineConfig.new(self, pipeline_id.to_sym, config_part, @settings)
        rescue => e
          raise LogStash::ConfigLoadingError, "logstash.modules.configuration.parse-failed"
        end
      end
      pipelines
    end

    def match?
      # will fill this later
      true
    end
  end 
end end end