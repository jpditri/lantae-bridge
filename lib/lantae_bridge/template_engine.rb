# frozen_string_literal: true

require 'erb'
require 'ostruct'

module LantaeBridge
  class TemplateEngine
    def initialize
      @templates_path = LantaeBridge.templates_path
    end

    def render(template_name, data = {})
      template_file = @templates_path.join("#{template_name}.erb")
      
      unless template_file.exist?
        raise Error, "Template not found: #{template_name}"
      end
      
      template = ERB.new(template_file.read, trim_mode: '-')
      context = OpenStruct.new(data)
      
      # Add helper methods to context
      context.define_singleton_method(:link) { |text| "[[#{text}]]" }
      context.define_singleton_method(:tag) { |text| "##{text.downcase.gsub(/\s+/, '-')}" }
      context.define_singleton_method(:property) { |key, value| "#{key}:: #{value}" }
      
      template.result(context.instance_eval { binding })
    end

    def available_templates
      Dir.glob(@templates_path.join('*.erb')).map do |file|
        File.basename(file, '.erb')
      end
    end

    def create_from_template(template_name, output_path, data = {})
      content = render(template_name, data)
      
      File.write(output_path, content)
      
      { success: true, output_path: output_path }
    rescue StandardError => e
      { success: false, error: e.message }
    end
  end
end