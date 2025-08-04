# frozen_string_literal: true

require 'fileutils'

module LantaeBridge
  class Converter
    def initialize(formatter: Formatter.new, linker: EntityLinker.new)
      @formatter = formatter
      @linker = linker
    end

    def convert_file(input_path, output_path = nil)
      content = File.read(input_path)
      
      # Format for Logseq
      formatted_content = @formatter.format_for_logseq(content)
      
      # Add entity links
      linked_content = @linker.add_links(formatted_content)
      
      # Write output
      output_path ||= input_path
      File.write(output_path, linked_content)
      
      { success: true, output_path: output_path }
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def convert_directory(dir_path, output_dir = nil)
      output_dir ||= dir_path
      results = []
      
      Dir.glob(File.join(dir_path, '**', '*.md')).each do |file|
        relative_path = Pathname.new(file).relative_path_from(Pathname.new(dir_path))
        output_path = File.join(output_dir, relative_path)
        
        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))
        
        result = convert_file(file, output_path)
        result[:file] = file
        results << result
      end
      
      results
    end

    def dry_run(input_path)
      content = File.read(input_path)
      
      # Format for Logseq
      formatted_content = @formatter.format_for_logseq(content)
      
      # Add entity links
      @linker.add_links(formatted_content)
    rescue StandardError => e
      "Error: #{e.message}"
    end
  end
end