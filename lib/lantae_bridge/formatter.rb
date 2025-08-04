# frozen_string_literal: true

module LantaeBridge
  class Formatter
    HEADER_REGEX = /^(#+)\s+(.+)$/
    PROPERTY_REGEX = /^(\w+):\s*(.+)$/
    YAML_FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m
    
    # Patterns that indicate list sections that should be indented under their parent
    LIST_SECTION_PATTERNS = [
      /^-?\s*Features?:/i,
      /^-?\s*Notable NPCs?:/i,
      /^-?\s*Hooks?:/i,
      /^-?\s*Adventure Hooks?:/i,
      /^-?\s*Dangers?:/i,
      /^-?\s*Equipment:/i,
      /^-?\s*Abilities:/i,
      /^-?\s*Skills:/i,
      /^-?\s*Stats?:/i,
      /^-?\s*Proficiencies:/i,
      /^-?\s*Languages:/i,
      /^-?\s*Special Abilities:/i,
      /^-?\s*Conversation Starters:/i,
      /^-?\s*Plot Hooks?:/i,
      /^-?\s*Character Arc Opportunities:/i,
      /^-?\s*Risks?:/i,
      /^-?\s*Vulnerabilities:/i
    ]

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

      # Track indentation hierarchy and list contexts
      indent_stack = []
      in_list_section = false
      
      lines.each_with_index do |line, index|
        formatted_line = process_line_with_hierarchy(line, indent_stack, in_list_section)
        formatted_lines << formatted_line unless formatted_line.nil?
        
        # Update list section tracking - more sophisticated approach
        if !line.strip.empty?
          if is_list_section?(line)
            in_list_section = true
          elsif line.match(HEADER_REGEX) || is_yaml_property_line?(line)
            # Headers or properties reset the list section context
            in_list_section = false
          elsif line.strip.start_with?('- ') && !in_list_section
            # If we see a bullet point but we're not in a list section,
            # check if this might be continuing from a previous list section
            in_list_section = false
          end
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
                    value.inspect  # Use inspect instead of to_json
                  else
                    value.to_s
                  end
      
      "#{key}:: #{value_str}"
    end

    def process_line_with_hierarchy(line, indent_stack, in_list_section)
      return line if line.strip.empty?

      # Handle headers - these define hierarchy levels
      if (match = line.match(HEADER_REGEX))
        header_level = match[1].length
        header_text = match[2]
        
        # Update indent stack to track current depth
        while indent_stack.length >= header_level
          indent_stack.pop
        end
        indent_stack[header_level - 1] = header_level
        
        # Convert to Logseq format with proper indentation
        indent = "\t" * (header_level - 1)
        return "#{indent}- #{'#' * header_level} #{header_text}"
      end

      # Check if this is a special list section (Features, Hooks, etc.)
      if is_list_section?(line)
        # List sections should be indented under their parent section
        current_indent = indent_stack.length > 0 ? indent_stack.length : 0
        indent = "\t" * current_indent
        
        # If it already starts with '- ', keep it, otherwise add it
        if line.strip.start_with?('- ')
          content = line.strip[2..-1]
        else
          content = line.strip
        end
        
        return "#{indent}- #{content}"
      end

      # Handle properties (key:: value format) 
      if line.match(PROPERTY_REGEX)
        # Properties within content sections get indented
        current_indent = indent_stack.length > 0 ? indent_stack.length : 0
        indent = "\t" * current_indent
        return "#{indent}- #{line.strip}"
      end

      # Handle existing bullet points
      if line.strip.start_with?('- ')
        # Get current indentation level from context
        base_indent = indent_stack.length > 0 ? indent_stack.length : 0
        
        # If we're in a list section context, add extra indentation for list items
        if in_list_section
          base_indent += 1
        end
        
        # Check if this line already has indentation (nested)
        existing_indent_match = line.match(/^(\t*)/)
        existing_tabs = existing_indent_match ? existing_indent_match[1].length : 0
        
        # Total indentation is base context plus any existing nesting
        total_indent = base_indent + existing_tabs
        
        indent = "\t" * total_indent
        content = line.strip[2..-1] # Remove the '- ' prefix
        return "#{indent}- #{content}"
      elsif line.strip.start_with?('* ')
        # Convert asterisk bullets to dash with proper indentation
        base_indent = indent_stack.length > 0 ? indent_stack.length : 0
        
        # If we're in a list section context, add extra indentation for list items
        if in_list_section
          base_indent += 1
        end
        
        existing_indent_match = line.match(/^(\t*)/)
        existing_tabs = existing_indent_match ? existing_indent_match[1].length : 0
        total_indent = base_indent + existing_tabs
        
        indent = "\t" * total_indent
        content = line.strip[2..-1] # Remove the '* ' prefix
        return "#{indent}- #{content}"
      end

      # Handle regular content lines (should be indented under current section)
      if line.strip.length > 0
        base_indent = indent_stack.length > 0 ? indent_stack.length : 0
        
        # If we're in a list section context, add extra indentation for items
        if in_list_section
          base_indent += 1
        end
        
        indent = "\t" * base_indent
        return "#{indent}- #{line.strip}"
      end

      line
    end

    def is_list_section?(line)
      LIST_SECTION_PATTERNS.any? { |pattern| line.match(pattern) }
    end

    def is_yaml_property_line?(line)
      line.match(PROPERTY_REGEX) && !line.strip.start_with?('- ')
    end
  end
end