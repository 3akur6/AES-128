AES-128 library do-it-myself

### Note
Only write for learning cryptography and easily calculating, don't take it serious.

Refer to the [Ruby OpenSSL documentation](http://ruby-doc.org/stdlib-2.0/libdoc/openssl/rdoc/OpenSSL.html)
for details on how to leverage AES in Ruby.

It is worth relating that I define Byte class of GF(2<sup>8</sup>) with [basic operations](#byte_class_usage) in `byte.rb`, such as `xtime`, `+`, `*`, `inverse`.You should have a try if you need to do some calculation among GF(2<sup>8</sup>).

### Usage
```
require_relative 'aes_128'

aes = AES_128.new(
  "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", # plain text
  "\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"  # key
)

aes.cipher
# The result is shown in array whose elements are decimal numbers.
# => [219, 119, 146, 48, 47, 100, 58, 56, 203, 172, 168, 79, 96, 119, 51, 91]
```

or you can get result of each micro step

```
require_relative 'aes_128'

aes = AES_128.new(
  "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", # plain text
  "\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"  # key
)

aes.add_round_key
# the first add-round-key step before ten rounds, which returns state matrix
# => Matrix[[1, 5, 9, 13], [0, 4, 8, 12], [3, 7, 11, 15], [2, 6, 10, 14]]

aes.byte_sub
# ByteSub step
# => Matrix[[124, 107, 1, 215], [99, 242, 48, 254], [123, 197, 43, 118], [119, 111, 103, 171]]
# or hex format
# Matrix[["7C", "6B", "01", "D7"], ["63", "F2", "30", "FE"], ["7B", "C5", "2B", "76"], ["77", "6F", "67", "AB"]]

aes.shift_row
# ShiftRow step
# => Matrix[[124, 107, 1, 215], [242, 48, 254, 99], [43, 118, 123, 197], [171, 119, 111, 103]]
# or hex format
# Matrix[["7C", "6B", "01", "D7"], ["F2", "30", "FE", "63"], ["2B", "76", "7B", "C5"], ["AB", "77", "6F", "67"]]

aes.mix_column
# MixColumn step
# => Matrix[[117, 135, 15, 178], [85, 230, 4, 34], [62, 46, 184, 140], [16, 21, 88, 10]]
# or hex format
# Matrix[["75", "87", "0F", "B2"], ["55", "E6", "04", "22"], ["3E", "2E", "B8", "8C"], ["10", "15", "58", "0A"]]

aes.add_round_key
# AddRoundKey step in each round
# => Matrix[[116, 134, 14, 179], [84, 231, 5, 35], [63, 47, 185, 141], [17, 20, 89, 11]]
# or hex format
# Matrix[["74", "86", "0E", "B3"], ["54", "E7", "05", "23"], ["3F", "2F", "B9", "8D"], ["11", "14", "59", "0B"]]
```

also you can get the result after each round quickly
```
require_relative 'aes_128'

aes = AES_128.new(
  "\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F", # plain text
  "\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01\x01"  # key
)

aes.add_round_key
# the first add-round-key step before ten rounds, which returns state matrix
# The step is necessary because it won't be called in 'round' function automatically
# => Matrix[[1, 5, 9, 13], [0, 4, 8, 12], [3, 7, 11, 15], [2, 6, 10, 14]]

aes.round
# do ByteSub -> ShiftRow -> MixColumn -> AddRoundKey one time
# => Matrix[[116, 134, 14, 179], [84, 231, 5, 35], [63, 47, 185, 141], [17, 20, 89, 11]]
# or hex format
# Matrix[["74", "86", "0E", "B3"], ["54", "E7", "05", "23"], ["3F", "2F", "B9", "8D"], ["11", "14", "59", "0B"]]
```

<span id = "byte_class_usage">Usage of Byte class</span>
```
require_relative 'byte'

a = Byte.new(0x51)

a.inverse
# returns the inverse element of 0x51, which is also an instance of Byte class
# => 0x5C

Byte.new(0x57) * Byte.new(0x13)
# => 0xFE

# or
Byte.new(0x57) * 0x13
```