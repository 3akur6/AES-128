require_relative 'byte'
require_relative 'key'

require 'matrix'

class AES_128
  AFFINE_SQUARE_MATRIX = Matrix[
    [1, 0, 0, 0, 1, 1, 1, 1],
    [1, 1, 0, 0, 0, 1, 1, 1],
    [1, 1, 1, 0, 0, 0, 1, 1],
    [1, 1, 1, 1, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 1, 1, 1, 1, 1]
  ]

  AFFINE_COLUMN_MATRIX = Matrix.columns([[1, 1, 0, 0, 0, 1, 1, 0]])

  MIX_COLUMN_MATRIX = Matrix[
    [2, 3, 1, 1],
    [1, 2, 3, 1],
    [1, 1, 2, 3],
    [3, 1, 1, 2]
  ]

  def initialize(m, k)
    raise 'param must be string' unless m.is_a?(String) and k.is_a?(String)
    m << 0.chr until (m.length % 16).zero?
    k << 0.chr until k.length >= 16
    @m = m
    @k = Key.new(k)

    @k.expansion(@m.length)
    @state_matrix = Matrix.columns(@m.bytes.each_slice(4).to_a)
  end

  def byte_sub
    @state_matrix.map! { |x| Byte.new(x).inverse.affine_transform.to_i rescue 99 }
  end

  def shift_row
    @state_matrix = Matrix.rows(@state_matrix.row_vectors.map.with_index { |x, idx| x.to_a.rotate(idx) })
  end

  def mix_column
    cache = []
    (0..3).each do |x|
      (0..3).each do |y|
        cache << (0..3).reduce(Byte.new(0)) do |memo, z|
          memo + Byte.new(MIX_COLUMN_MATRIX[x, z]) * Byte.new(@state_matrix[z, y])
        end
      end
    end
    @state_matrix = Matrix.rows(cache.each_slice(4).to_a).map { |x| x.to_i }
  end

  def add_round_key
    @state_matrix.map!.with_index { |x, idx| x ^ @k.expanded_key[idx] }
  end

  def round
    byte_sub
    shift_row
    mix_column
    add_round_key
  end

  def final_round
    byte_sub
    shift_row
    add_round_key
  end

  def cipher
    return @c if defined? @c
    add_round_key
    9.times { round }
    @c = final_round.to_a.flatten
  end
end

class Byte
  def to_matrix
    Matrix.columns([self.to_s(2).chars.reverse.map { |it| it.to_i }])
  end

  def affine_transform
    Byte.new(
      (AES_128::AFFINE_SQUARE_MATRIX * self.to_matrix +
        AES_128::AFFINE_COLUMN_MATRIX).map { |x| x % 2 }.transpose.row(0).to_a.reverse.join.to_i(2)
    )
  end
end