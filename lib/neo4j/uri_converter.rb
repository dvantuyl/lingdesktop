class UriConverter
  class << self
    def to_java(value)
      return nil if value.nil?
      puts "CONVERT: #{value}"
      URI.escape(value, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
    
    def to_ruby(value)
      return nil if value.nil?
      puts "TO_RUBY: #{value}"
      URI.unescape(value)
    end
  end
end