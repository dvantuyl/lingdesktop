
class String
  
  def md5
    Digest::MD5.hexdigest(self)
  end
  
  def uri_encode
    URI.escape(self, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
  
  def uri_decode
    URI.unescape(self)
  end
  
end