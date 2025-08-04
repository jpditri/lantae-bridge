# frozen_string_literal: true

module LantaeBridge
  class Validator
    VALIDATIONS = {
      properties: :validate_properties,
      headers: :validate_headers,
      bullets: :validate_bullets,
      links: :validate_links
    }.freeze

    def validate_file(file_path)
      content = File.read(file_path)
      errors = []
      warnings = []
      
      VALIDATIONS.each do |check_name, method|
        result = send(method, content)
        errors.concat(result[:errors]) if result[:errors]
        warnings.concat(result[:warnings]) if result[:warnings]
      end
      
      {
        valid: errors.empty?,
        errors: errors,
        warnings: warnings,
        file: file_path
      }
    rescue StandardError => e
      {
        valid: false,
        errors: ["Failed to read file: #{e.message}"],
        warnings: [],
        file: file_path
      }
    end

    def validate_directory(dir_path)
      results = []
      
      Dir.glob(File.join(dir_path, '**', '*.md')).each do |file|
        results << validate_file(file)
      end
      
      results
    end

    private

    def validate_properties(content)
      errors = []
      warnings = []
      
      lines = content.lines
      property_lines = lines.select { |line| line.match(/^\w+::/) }
      
      # Check if properties are at the beginning
      if property_lines.any? && !lines.first.match(/^\w+::/)
        warnings << "Properties should be at the beginning of the file"
      end
      
      # Check for malformed properties
      lines.each_with_index do |line, index|
        if line.match(/^\w+:\s/) && !line.match(/^\w+::/)
          errors << "Line #{index + 1}: Property should use '::' not ':'"
        end
      end
      
      { errors: errors, warnings: warnings }
    end

    def validate_headers(content)
      errors = []
      warnings = []
      
      lines = content.lines
      
      lines.each_with_index do |line, index|
        # Check for headers not in bullet format
        if line.match(/^#+\s+\w/) && !line.match(/^-\s*#+/)
          errors << "Line #{index + 1}: Header should be in bullet format (- # Header)"
        end
      end
      
      { errors: errors, warnings: warnings }
    end

    def validate_bullets(content)
      errors = []
      warnings = []
      
      lines = content.lines
      
      # Check that content uses bullets
      content_lines = lines.reject { |l| l.strip.empty? || l.match(/^\w+::/) }
      non_bullet_lines = content_lines.reject { |l| l.match(/^[\s\t]*-/) }
      
      if non_bullet_lines.any?
        warnings << "#{non_bullet_lines.size} lines without bullet points found"
      end
      
      { errors: errors, warnings: warnings }
    end

    def validate_links(content)
      errors = []
      warnings = []
      
      # Check for broken link syntax
      if content.match(/\[\[\[/)
        errors << "Triple brackets found - possible linking error"
      end
      
      if content.match(/\]\]\]/)
        errors << "Triple closing brackets found - possible linking error"
      end
      
      # Check for markdown style links
      if content.match(/\[([^\]]+)\]\(([^)]+)\)/)
        warnings << "Markdown-style links found - consider using [[wikilinks]]"
      end
      
      { errors: errors, warnings: warnings }
    end
  end
end