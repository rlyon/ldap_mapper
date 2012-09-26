class String
  class << self
    def random(args = { :length => 24, :charset => :all })
      if args[:charset] == :alpha
        chars = ('a'..'z').to_a + ('A'..'Z').to_a
      elsif args[:charset] == :alnum_upper
        chars = ('A'..'Z').to_a + ('0'..'9').to_a
      else
        chars = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a
      end
      (0...args[:length]).collect { chars[Kernel.rand(chars.length)] }.join  
    end
  end  
end
