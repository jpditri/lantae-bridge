# frozen_string_literal: true

module LantaeBridge
  class Formatter
    HEADER_REGEX = /^(#+)\s+(.+)$/
    PROPERTY_REGEX = /^(\w+):\s*(.+)$/
    YAML_FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m

    def format_for_logseq(content)
      # Remove YAML front matter if present
      yaml_data = extract_yaml_front_matter(content)
      content = content.sub(YAML_FRONT_MATTER_REGEX, '') if yaml_data

      lines = content.lines.map(&:chomp)
      formatted_lines = []
      
      # Add properties from YAML if present
      if yaml_data
        formatted_lines.concat(format_properties(yaml_data))
        formatted_lines << ''
      end

      current_indent = 0
      
      lines.each do |line|
        formatted_line = process_line(line, current_indent)
        formatted_lines << formatted_line unless formatted_line.nil?
        
        # Track indentation for nested content
        if line.match(HEADER_REGEX)
          current_indent = $1.length - 1
        elsif line.strip.empty?
          current_indent = 0
        end
      end

      formatted_lines.join("\n")
    end

    private

    def extract_yaml_front_matter(content)
      match = content.match(YAML_FRONT_MATTER_REGEX)
      return nil unless match

      begin
        YAML.safe_load(match[1])
      rescue StandardError
        nil
      end
    end

    def format_properties(yaml_data)
      yaml_data.map do |key, value|
        format_property(key, value)
      end
    end

    def format_property(key, value)
      value_str = case value
                  when Array
                    value.join(', ')
                  when Hash
                    value.to_json
                  else
                    value.to_s
                  end
      
      "#{key}:: #{value_str}"
    end

    def process_line(line, indent_level)
      # Handle headers
      if (match = line.match(HEADER_REGEX))
        header_level = match[1].length
        header_text = match[2]
        
        # Convert to Logseq outliner format
        return "- #{'#' * header_level} #{header_text}"
      end

      # Handle properties not in YAML
      if line.match(PROPERTY_REGEX) && indent_level == 0
        return line # Properties are already in correct format
      end

      # Handle bullet points
      if line.strip.start_with?('- ')
        return line # Already in bullet format
      elsif line.strip.start_with?('* ')
        # Convert asterisk bullets to dash
        return line.sub(/^\s*\*/, '-')
      end

      # Handle regular content
      if line.strip.empty?
        return line
      else
        # Add bullet if not present
        indent = "\t" * indent_level
        return "#{indent}- #{line.strip}"
      end
    end
  end
end