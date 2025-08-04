# frozen_string_literal: true

module LantaeBridge
  class Formatter
    HEADER_REGEX = /^(#+)\s+(.+)$/
    PROPERTY_REGEX = /^([A-Za-z][A-Za-z0-9\s]*?):\s*(.*)$/
    YAML_FRONT_MATTER_REGEX = /\A---\s*\n(.*?)\n---\s*\n/m
    
    # Properties that should remain as Logseq properties, not become headers
    PROPERTY_KEYS = [
      'type', 'description', 'parent_location_id', 'parent location id', 'coordinates', 'population', 
      'government', 'notable_features', 'history', 'current_events', 'current events', 'secrets', 
      'status', 'race', 'npc_class', 'alignment', 'cr', 'str', 'dex', 'con', 
      'int', 'wis', 'cha', 'hp', 'ac', 'speed', 'abilities', 'attacks', 
      'combat_tactics', 'campaign', 'location', 'level', 'background', 'tags',
      'notable_npcs', 'notable npcs', 'region', 'summary', 'name', 'id', 'campaign_id', 
      'campaign_slug'
    ].map(&:downcase)
    
    # Patterns that indicate list sections that should become subheaders
    # These are sections that typically have list items underneath them
    LIST_SECTION_PATTERNS = [
      /^-?\s*Features?:\s*$/i,
      /^-?\s*Hooks?:\s*$/i,
      /^-?\s*Adventure Hooks?:\s*$/i,
      /^-?\s*Dangers?:\s*$/i,
      /^-?\s*Equipment:\s*$/i,
      /^-?\s*Abilities:\s*$/i,
      /^-?\s*Skills:\s*$/i,
      /^-?\s*Special Abilities:\s*$/i,
      /^-?\s*Conversation Starters:\s*$/i,
      /^-?\s*Plot Hooks?:\s*$/i,
      /^-?\s*Character Arc Opportunities:\s*$/i,
      /^-?\s*Risks?:\s*$/i,
      /^-?\s*Vulnerabilities:\s*$/i
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
        
        # Update list section tracking - list sections are now headers
        if !line.strip.empty?
          if is_list_section?(line)
            # List sections are now converted to headers, so we're entering a list context
            in_list_section = true
          elsif line.match(HEADER_REGEX) && !is_list_section?(line)
            # Regular headers reset the list section context
            in_list_section = false
          elsif is_yaml_property_line?(line)
            # Properties reset the list section context
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
        # Convert list sections to proper subheaders
        # For simple entity files, list sections should be ## level headers
        header_level = 2
        
        # Clean up the section name - remove bullets and colons
        section_name = line.strip
        section_name = section_name.sub(/^-\s*/, '')  # Remove leading bullet
        section_name = section_name.sub(/:+\s*$/, '') # Remove trailing colons
        
        # Update indent stack for this new header level
        while indent_stack.length >= header_level
          indent_stack.pop
        end
        indent_stack[header_level - 1] = header_level
        
        # Create proper subheader with Logseq formatting
        indent = "\t" * (header_level - 1)
        return "#{indent}- #{'#' * header_level} #{section_name}"
      end

      # Handle properties (key: value format)
      if (match = line.match(PROPERTY_REGEX))
        property_key = match[1].strip.downcase
        property_value = match[2].strip
        
        # Check if this is a known property that should use :: format
        if PROPERTY_KEYS.include?(property_key)
          # Convert to Logseq property format
          current_indent = indent_stack.length > 0 ? indent_stack.length : 0
          indent = "\t" * current_indent
          return "#{indent}- #{match[1].strip}:: #{property_value}"
        else
          # Regular content line
          current_indent = indent_stack.length > 0 ? indent_stack.length : 0
          indent = "\t" * current_indent
          return "#{indent}- #{line.strip}"
        end
      end

      # Handle existing bullet points
      if line.strip.start_with?('- ')
        # Get current indentation level from context
        base_indent = indent_stack.length > 0 ? indent_stack.length : 0
        
        # Check if this line already has indentation (nested)
        existing_indent_match = line.match(/^(\t*)/)
        existing_tabs = existing_indent_match ? existing_indent_match[1].length : 0
        
        # Total indentation is base context plus any existing nesting
        total_indent = base_indent + existing_tabs
        
        indent = "\t" * total_indent
        content = line.strip[2..-1] # Remove the '- ' prefix
        
        # Check if the content is a property that should use :: format
        # But skip if it's already in :: format
        if (match = content.match(PROPERTY_REGEX)) && !content.include?('::')
          property_key = match[1].strip.downcase
          property_value = match[2].strip
          
          if PROPERTY_KEYS.include?(property_key)
            return "#{indent}- #{match[1].strip}:: #{property_value}"
          end
        end
        
        return "#{indent}- #{content}"
      elsif line.strip.start_with?('* ')
        # Convert asterisk bullets to dash with proper indentation
        base_indent = indent_stack.length > 0 ? indent_stack.length : 0
        
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
        
        indent = "\t" * base_indent
        return "#{indent}- #{line.strip}"
      end

      line
    end

    def is_list_section?(line)
      LIST_SECTION_PATTERNS.any? { |pattern| line.match(pattern) }
    end

    def is_yaml_property_line?(line)
      if (match = line.match(PROPERTY_REGEX))
        property_key = match[1].strip.downcase
        PROPERTY_KEYS.include?(property_key) && !line.strip.start_with?('- ')
      else
        false
      end
    end
  end
end