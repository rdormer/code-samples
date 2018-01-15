# Author::    Robert Dormer (mailto:rdormer@gmail.com)

class LocationNumeral

  attr_reader :value

  @@values = {}
  @@alphabet = {}

  #Constructor, which ALWAYS takes ONLY a string
  #corresponding to the location number for this object.
  #We also have a pair of lookup tables which are useful,
  #and these are initialized if they haven't already been.

  def initialize(value)
    raise ArgumentError unless value.is_a? String
    raise ArgumentError unless is_valid_number(value)
    @value = value.upcase
  
    if @@values.empty?
      start = 'A'
      (0..25).each do |i| 
        @@alphabet[i] = start.clone
        @@values[start] = i
        start.next!
      end
    end
  end 

  #location -> integer
  #Convert either this object, or, optionally, a passed in string
  #corresponding to a location number to it's integer representation.  
  #Just iterate over the individual digits of the number and multiply
  #by their values in the index lookup table

  def to_i(s=@value)
    raise ArgumentError unless s.is_a? String
    bits = s.upcase.chars.to_a 
    bits.reduce(0) {|sum, current| sum += (2 ** @@values[current])}
  end

  #integer -> location
  #Convert either this object, or, optionally, a passed in integer
  #into the corresponding abbreviated location number.  We do this
  #by converting the number to binary, and then using the bits as
  #a mask to determine which digits to pull out of our lookup table
  #of letters, with a special case for indices greater than 25.  
  #Because of the binary conversion the resulting number is 
  #guaranteed to be in abbreviated form.

  def to_abbrev(ivalue=self.to_i)
    raise ArgumentError unless ivalue.is_a? Fixnum
    binary_rep = ivalue.to_s(2).reverse.each_char.to_a
    location = ''

    binary_rep.each_with_index do |bit, index|
      if bit == '1'
        if index < 26
          location += @@alphabet[index]
        else
          location += String.new('ZZ' * ((index - 26) + 1)) 
        end
      end
    end
 
    location
  end 

  #location -> abbreviated location
  #Convert either this object, or an optional passed in string
  #corresponding to a location number into it's abbreviated form.

  def abbreviate_location(input=@value)
    raise ArgumentError unless input.is_a? String
    raise ArgumentError unless is_valid_number(input)
    int_value = to_i(input)
    to_abbrev(int_value)
  end

  #operators
  def +(value)
    binary_operator(value) do |op1, op2|
      op1 + op2
    end
  end

  #My understanding of location numbers is that
  #zero and negative numbers are not possible/allowed,
  #so we check for that with subtraction

  def -(value)
    binary_operator(value) do |op1, op2|
      val = op1 - op2
      raise 'Underflow' if val <= 0
      val  
    end
  end

  def *(value)
    binary_operator(value) do |op1, op2|
      op1 * op2
    end
  end

  #Not entirely sure how you'd divide by zero, since you can't
  #make one, but check for it anyway just in case

  def /(value)
    binary_operator(value) do |op1, divisor|
      raise 'Divide by Zero' if divisor.zero? 
      op1 / divisor
    end
  end

  def **(value)
    binary_operator(value) do |base, exp|
      base ** exp
    end
  end

  def ==(value)
    boolean_operator(value) do |op1, op2|
      op1 == op2
    end
  end

  def <(value)
    boolean_operator(value) do |op1, op2|
      op1 < op2
    end
  end
  
  def >(value)
    boolean_operator(value) do |op1, op2|
      op1 > op2
    end
  end

  def <=(value)
    boolean_operator(value) do |op1, op2|
      op1 <= op2
    end
  end

  def >=(value)
    boolean_operator(value) do |op1, op2|
      op1 >= op2
    end
  end
 
  private

  def binary_operator(value)
    if value.is_a? LocationNumeral
      value_1 = self.to_i
      value_2 = value.to_i
      lvalue = yield value_1, value_2
      locvalue = to_abbrev(lvalue)
      LocationNumeral.new(locvalue)
    else
      raise ArgumentError
    end
  end

  def boolean_operator(value)
    if value.is_a? LocationNumeral
      value_1 = self.to_i
      value_2 = value.to_i
      yield value_1, value_2
    else
      raise ArgumentError
    end
  end
     
  #A valid location number will have letters ONLY

  def is_valid_number(num)
    num.chars.to_a.all? {|c| c =~ /[A-Z]/i}
  end
end
