module LdapMapper
  class Filter
    def initialize(op, lhs, *rhs)
      @op = op
      @lhs = lhs
      if rhs.size > 1
        @rhs = rhs
      else
        @rhs = rhs.first
      end
    end

    def to_rfc2254
      case @op
      when :eq
        "#{@lhs}=#{@rhs}"
      when :lte
        "#{@lhs}<=#{@rhs}"
      when :gte
        "#{@lhs}>=#{@rhs}"
      when :not
        "!(#{@lhs.to_rfc2254})"
      when :and
        if @rhs.is_a?(Array)
          rhs = @rhs.inject("") { |s, r| s += "(#{r.to_rfc2254})" ; s }
        else
          rhs = "(#{@rhs.to_rfc2254})"
        end
        "&(#{@lhs.to_rfc2254})#{rhs}"
      when :or
        if @rhs.is_a?(Array)
          rhs = @rhs.inject("") { |s, r| s += "(#{r.to_rfc2254})" ; s }
        else
          rhs = "(#{@rhs.to_rfc2254})"
        end
        "|(#{@lhs.to_rfc2254})#{rhs}"
      else
        raise "Not implemented"
      end
    end

    def to_s
      "(#{to_rfc2254})"
    end

    class << self
      def and(lhs, *rhs)
        new(:and, lhs, *rhs)
      end

      def or(lhs, *rhs)
        new(:or, lhs, *rhs)
      end

      def not(lhs)
        new(:not, lhs, nil)
      end

      def eq(lhs, rhs)
        new(:eq, lhs, rhs)
      end

      def gte(lhs, rhs)
        new(:gte, lhs, rhs)
      end

      def lte(lhs, rhs)
        new(:lte, lhs, rhs)
      end
    end
  end
end
