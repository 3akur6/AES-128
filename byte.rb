class Byte
  include Comparable

  attr_accessor :value

  def initialize(v)
    raise 'object must be among 0x00 and 0xFF' unless v.byte?
    @value = v
  end

  def xtime
    flag = @value & 0x80
    tmp = (@value << 1) & 0xFF
    case flag
    when 0x00 then Byte.new(tmp)
    when 0x80 then Byte.new(tmp ^ 0x1B)
    end
  end

  def inspect
    "0x#{@value.to_s(16).upcase}"
  end

  def to_s(base)
    if base == 2
      "%08d" % @value.to_s(2)
    else
      @value.to_s(base)
    end
  end

  def to_i
    @value
  end

  def <=>(param)
    param = Byte.new(param) unless param.is_a?(Byte)
    self.value <=> param.value
  end

  def *(param)
    param = Byte.new(param) unless param.is_a?(Byte)
    before = self
    result = Byte.new(0)
    cpy = param.value
    while cpy.nonzero?
      result = result + before if (cpy & 1).nonzero?
      before = before.xtime
      cpy >>= 1
    end
    result
  end

  def /(param)
    param = Byte.new(param) unless param.is_a?(Byte)
    raise ZeroDivisionError if param == 0
    cpy = self
    result = 0
    while (step = cpy.value.to_s(2).length - param.value.to_s(2).length) >= 0
      cpy -= (param.value << step)
      result += (1 << step)
      break if cpy == 0
    end
    Byte.new(result)
  end

  def %(param)
    param = Byte.new(param) unless param.is_a?(Byte)
    raise ZeroDivisionError if param == 0
    self - (self / param) * param
  end

  def +(param)
    param = Byte.new(param) unless param.is_a?(Byte)
    Byte.new(@value ^ param.value)
  end

  alias :- :+

  def -@
    Byte.new(0) - self
  end

  # a(x)*b(x)=1(mod m(x))
  def inverse
    raise '0 has no inverse element' if self == 0
    return Byte.new(1) if self == 1
    a = self
    m = 0x11B
    result = 0
    while (step = m.to_s(2).length - a.value.to_s(2).length) >= 0
      m ^= (a.value << step)
      result += (1 << step)
    end

    mul = a.value.to_s(2).chars.map { |it| it.to_i }.reverse.map.with_index { |x, idx| (result * x) << idx }.reduce(0) { |sum, it| sum ^ it }

    cache = [0, 1].map! { |it| Byte.new(it) }
    cache << cache[0] - cache[1] * result

    a, m = Byte.new(0x11B ^ mul), a
    i = 3
    until (t = m % a) == 0
      cache << cache[i - 2] - cache[i - 1] * (m / a)
      a, m = t, a
      i += 1
    end
    cache[-1]
  end
end

# monkey patch for Integer
class Integer
  def byte?
    (0x00..0xFF).include?(self)
  end
end