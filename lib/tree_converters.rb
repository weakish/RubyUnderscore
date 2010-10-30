#!/usr/bin/env ruby
require 'pp'

gem 'ParseTree', '=3.0.5'
require 'sexp_processor'
require 'ruby2ruby'
require 'unified_ruby'
require 'parse_tree'

class AbstractProcessor < SexpProcessor
  def initialize
    super
    @alternate = SexpProcessor.new
  end

  def proceed(exp)
    @alternate.process exp
  end

  def assert_empty(meth, exp, exp_orig)

  end
end

module EnhancerHelper
  # Deep Clone or arrays. Focused on arrays to be converted into sexp.
  def clone(array)
    a = []
    array.each do | x |
      a << if x.is_a? Array
        clone(x)
      elsif x.is_a? Symbol or x.is_a? Fixnum
        x
      else
        x.clone
      end
    end
    a
  end

  def chain(sexp, *processorClasses)
    processorClasses.inject(sexp) do |memo, clas|
      clas.new.process memo
    end
  end

  def needsEnhancing(clas, method)
    sexpNeedsEnhancing sexpOf clas, method
  end


  def sexpOf(clas, method)
    ParseTree.translate clas, method
  end

  def sexpNeedsEnhancing(sexp)
    return false if sexp.nil?
    parser = EnhancerDetector.new
    parser.process clone sexp
    return parser.needsEnhancing
  end

  def assertSexpIs(sexp, type)
    raise "Wrong sexp type: #{sexp.first}" unless sexp.first == type
  end

  class EnhancerDetector < AbstractProcessor
    attr_reader :needsEnhancing

    def initialize
      super
      @needsEnhancing = false
    end

    def process_vcall(sexp)
      return s *sexp unless sexp[1] == :_
      @needsEnhancing = true
      s()
    end
  end
end



class VcallEnhancer < AbstractProcessor
  attr_accessor :lookingForVcall
  include EnhancerHelper
  public :s
  class AbstractSexp
    attr_reader :sexp, :enhancer

    include EnhancerHelper
    def initialize(sexp, enhancer)
      assertSexpIs sexp, type
      @sexp = sexp
      @enhancer = enhancer
      deconstruct sexp[1..-1]
    end

    def s(*args)
      enhancer.s *args
    end

    def process(arg)
      enhancer.process arg
    end

    def lookingForVcall(sexp)
      enhancer.lookingForVcall sexp
    end

    def variableName
      enhancer.variableName
    end


    def processSelf(newArgs)
      self.args = newArgs
      regularEnhance
    end

    def regularEnhance
      return s *asArray unless args
      s *asArray.push(process(args))
    end

    def enhance
      return regularEnhance unless sexpNeedsEnhancing args
      enhancer.lookingForVcall = true
      newArgs = process args
      return processSelf newArgs unless enhancer.lookingForVcall
      enhancer.lookingForVcall = false
      return s(:iter, s(*asArray), s(:dasgn_curr, variableName),
        newArgs[1])
    end



    def deconstruct(sexp)
      raise "subclass responsability"
    end

    def type
      raise "subclass responsability"
    end

    def asArray
      raise "subclass responsability"
    end

  end

  class Fcall < AbstractSexp
    attr_accessor :method, :args
    def type
      :fcall
    end

    def deconstruct(sexp)
      @method, @args = sexp
    end


    def asArray
      [type, method]
    end


  end

  class Call < AbstractSexp
    attr_accessor :method, :args, :target
    def type
      :call
    end
    
    def deconstruct(sexp)
      @target, @method, @args = sexp
    end

    def asArray
      [type, process(target), method]
    end

  end

  def initialize
    super
    self.lookingForVcall = false
  end

  def variableName
    :x
  end

  def process_vcall(sexp)
    return s *sexp unless sexp[1] == :_
    s(:dvar, variableName)
  end

  def process_call(sexp)
    changeGenericCall sexp
  end

  def process_fcall(sexp)
    changeGenericCall sexp
  end

  def changeGenericCall(sexp)
    sexpClass(sexp.first).new(sexp, self).enhance
  end

  protected
  def sexpClass(type)
    return Call if type == :call
    return Fcall if type == :fcall
    raise "Unknown sexp: #{type}"
  end

end


class UnderscoreEnhancer
  include EnhancerHelper

  def enhance(clas, method)
    sexp = sexpOf clas, method
    return unless sexpNeedsEnhancing sexp
    clas.class_eval chain sexp, VcallEnhancer, Unifier, Ruby2Ruby
  end

end

# Next test case: it has to be the closest fcall to vcall_. calls with args to the _vcall,
# are just ignored
#class A
#  def x
#    invoke go _.to_i
#  end
#end
#
#u = UnderscoreEnhancer.new
#pp u.sexpOf A, :x
#p A.new.x