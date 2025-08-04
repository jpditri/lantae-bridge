# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'pathname'
require 'colorize'

require_relative 'lantae_bridge/version'
require_relative 'lantae_bridge/formatter'
require_relative 'lantae_bridge/converter'
require_relative 'lantae_bridge/validator'
require_relative 'lantae_bridge/template_engine'
require_relative 'lantae_bridge/entity_linker'

module LantaeBridge
  class Error < StandardError; end
  
  class << self
    def root
      @root ||= Pathname.new(File.expand_path('..', __dir__))
    end

    def templates_path
      root.join('lib', 'templates')
    end

    def config
      @config ||= load_config
    end

    private

    def load_config
      config_file = root.join('config', 'lantae_bridge.yml')
      return {} unless config_file.exist?

      YAML.load_file(config_file) || {}
    rescue StandardError => e
      warn "Failed to load config: #{e.message}"
      {}
    end
  end
end