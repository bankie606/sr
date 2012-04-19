# This monkey patch for Hash allows us to query json
# objects with symbols
class Hash
  alias_method :original_bracket, :[]
end

class Hash
  def [](key)
    if key.is_a?(Symbol) && original_bracket(key).nil?
      original_bracket(key.to_s)
    else
      original_bracket(key)
    end
  end
end

