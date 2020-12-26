class Key
  attr_reader :cipher_key, :expanded_key

  def initialize(k)
    @cipher_key = k
    @expanded_key = k.bytes
  end

  def expansion(len)
    return @expanded_key if @expanded_key.length >= len
    i = @expanded_key.length / 4
    while @expanded_key.length < len
      tmp = @expanded_key[((i - 1) * 4)...(i * 4)]
      if (i % 4).zero?
        tmp = tmp.rotate.map.with_index do |x, idx|
          (Byte.new(x).inverse.affine_transform.to_i rescue 99) ^
            (idx.zero? ? (1 << (i / 4 - 1)) : 0)
        end
      end
      @expanded_key.concat(tmp.map.with_index { |x, idx| x ^ @expanded_key[(i - 4) * 4 + idx] })
      i += 1
    end
    @expanded_key
  end
end