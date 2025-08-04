# frozen_string_literal: true

module LantaeBridge
  class EntityLinker
    # Common entity patterns to auto-link
    ENTITY_PATTERNS = {
      locations: /\b(Salem|Lynn Woods|Boston|Mascas|Eliozor|Narrow Sectarian|Saljaimer|Estonia|Grimore|Jorbundo|Ice[- ]Goblin[- ]Mountain|Kepharion)\b/i,
      npcs: /\b(Beverly Martinez|Madison Scott|Athena|Lord Krolus|King Everec|Princess Katzen|Queen Elsuon|Trebor Nodrog|Botan|Ikerdal|King Shabaku)\b/i,
      factions: /\b(Order of Krolus|Coven Sisters|The Heretical|House of Blackrock Crow)\b/i,
      concepts: /\b(xenocortex|bio-crystalline|pattern-locking|dual cognition)\b/i
    }.freeze

    def add_links(content)
      linked_content = content.dup
      
      ENTITY_PATTERNS.each do |_category, pattern|
        linked_content.gsub!(pattern) do |match|
          # Don't double-link already linked content
          if already_linked?(linked_content, match)
            match
          else
            "[[#{match}]]"
          end
        end
      end
      
      # Fix any double-bracketed links
      linked_content.gsub!(/\[\[\[+/, '[[')
      linked_content.gsub!(/\]\]\]+/, ']]')
      
      linked_content
    end

    private

    def already_linked?(content, match)
      # Check if the match is already within double brackets
      index = content.index(match)
      return false unless index
      
      # Look for [[ before and ]] after
      before_index = [0, index - 2].max
      after_index = [content.length, index + match.length + 2].min
      
      before = content[before_index, 2]
      after = content[index + match.length, 2]
      
      before == '[[' || after == ']]'
    end
  end
end