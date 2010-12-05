
class String
  
  def md5
    Digest::MD5.hexdigest(self)
  end
  
  def uri_esc
    URI.escape(self, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
  
  def uri_unesc
    URI.unescape(self)
  end
  
end