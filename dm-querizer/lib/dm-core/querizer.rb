module DataMapper
  class Querizer
    self.instance_methods.each { |m| send(:undef_method, m) unless m =~ /^(__|instance_eval)/ }

    Hash['==',:eql,'=~',:like,'>=',:gte,'<=',:lte,'>',:gt,'<',:lt,'~',:not].each do |opr,to|
      class_eval <<-EOS, __FILE__, __LINE__
        def #{opr}(val); @conditions << condition(val,:#{to}); end
      EOS
    end

    def condition(value,opr)
      condition = @stack.length > 1 ? eval(@stack * '.') : @stack.pop
      condition = condition.send(opr) if condition.respond_to?(opr) && opr != :eql
      value = @value_stack if value.class == self
      @stack.clear
      [condition,value]
    end

    def self.translate(&block)
      (@instance||=self.new).translate(&block)
    end

    def translate(&block)
      @stack,@value_stac, @conditions = [], [], []

      self.instance_eval(&block)

      query = {}
      @conditions.each {|c| query[c[0]] = c[1]}
      puts query.inspect
      return query
    end

    def method_missing(method,value=nil)
      puts method
      @stack << method
      self
    end
  end
end