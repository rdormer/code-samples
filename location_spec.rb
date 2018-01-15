# Author::    Robert Dormer (mailto:rdormer@gmail.com)

load 'location.rb'

describe LocationNumeral do

  describe 'parsing' do
    it 'should not accept malformed data' do
      expect{described_class.new('ABCDEF')}.to_not raise_error
      expect{described_class.new(1234)}.to raise_error ArgumentError
      expect{described_class.new('AB123')}.to raise_error ArgumentError
    end

    it 'should accept lower case letters' do
      expect{described_class.new('abcdef')}.to_not raise_error
      expect(described_class.new('aa').to_i).to eq 2
    end

    it 'should parse single letters properly' do
      letter = 'A'
      counter = 1

      until letter == 'Z' do
        expect(described_class.new(letter).to_i).to eq counter
        counter *= 2
        letter.next!
      end
    end

    it 'should parse specified examples properly' do
      expect(described_class.new('AD').to_i).to eq 9
    end

    it 'should handle numbers larger than 2 ^ 26' do
      value = described_class.new('ZZZ')
      expect(value.to_i > (2 ** 26)).to be true
    end

    it 'should handle numbers *way* larger than 2 ^ 26' do
      bigvalue = described_class.new(String.new('Z' * 200))
      expect(bigvalue.to_i / (2 ** 26)).to eq 100
    end
  end

  describe 'abbreviating' do
    it 'should collapse two letter combinations' do
      letter = 'A'
      next_letter = 'B'
 
      until next_letter == 'Z' do
        second = described_class.new(next_letter)
        first = described_class.new(letter + letter)
        expect(first.to_i).to eq second.to_i
        next_letter.next!
        letter.next!
      end
    end

    it 'should collapse three letter combinations with remainder' do
      letter = 'A'
      next_letter = 'B'
 
      until next_letter == 'Z' do
        second = described_class.new(next_letter + letter)
        first = described_class.new(letter + letter + letter)
        expect(first.to_i).to eq second.to_i
        next_letter.next!
        letter.next!
      end
    end

    it 'should collapse to the largest possible power of two' do
      letter = 'A'
      next_letter = 'C'
 
      until next_letter == 'Z' do
        first = described_class.new(letter * 4)
        second = described_class.new(next_letter)
        expect(first.to_i).to eq second.to_i
        next_letter.next!
        letter.next!
      end
    end
  end

  describe '#abbreviate_location' do
    it 'should collapse two letter combinations' do
      letter = 'A'
      next_letter = 'B'
 
      until next_letter == 'Z' do
        num = described_class.new(letter + letter)
        expect(num.abbreviate_location).to eq next_letter
        next_letter.next!
        letter.next!
      end
    end

    it 'should collapse three letter combinations with remainder' do
      letter = 'A'
      next_letter = 'B'
 
      until next_letter == 'Z' do
        num = described_class.new(letter + letter + letter)
        expect(num.abbreviate_location).to eq(letter + next_letter)
        next_letter.next!
        letter.next!
      end
    end

    it 'should collapse to the largest possible power of two' do
      letter = 'A'
      next_letter = 'C'
 
      until next_letter == 'Z' do
        num = described_class.new(letter * 4)
        expect(num.abbreviate_location).to eq next_letter
        next_letter.next!
        letter.next!
      end
    end

    it 'should not abbreviate what cannot be abbreviated' do
      value = described_class.new('ZZZZZ')
      expect(value.abbreviate_location).to eq 'ZZZZZ'
    end
  end

  describe 'integer conversion' do
  end

  describe 'operators' do
    before(:each) do
      @first_number = described_class.new('A')
      @second_number = described_class.new('B')
    end

    describe 'arithmetic operators' do
      it 'should support addition' do
        result = @first_number + @second_number
        expect(result.value).to eq 'AB'
        expect(result.to_i).to eq 3 
      end

      it 'should support subtraction' do
        result = @second_number - @first_number
        expect(result.value).to eq 'A'
        expect(result.to_i).to eq 1
      end

      it 'should raise error on subtraction that results in negative numbers' do
        expect{@first_number - @second_number}.to raise_error 'Underflow'
      end
  
      it 'should support division' do
        divisor = described_class.new('Y')
        result = divisor / @second_number
        expect(result.value).to eq 'X'
        expect(result.to_i).to eq 8388608 
      end

      it 'should support multiplication' do
        result = @second_number * @second_number
        expect(result.value).to eq 'C'
        expect(result.to_i).to eq 4
      end

      it 'should support exponentiation' do
        result = @second_number ** @second_number
        expect(result.value).to eq 'C'
        expect(result.to_i).to eq 4
      end

      it 'should raise errors if not passed a LocationNumeral' do
        expect{@first_number + 1}.to raise_error ArgumentError
        expect{@first_number - 1}.to raise_error ArgumentError
        expect{@first_number * 1}.to raise_error ArgumentError
        expect{@first_number / 1}.to raise_error ArgumentError
        expect{@first_number ** 1}.to raise_error ArgumentError
      end
    end

    describe 'boolean operators' do
      it 'should support equality' do
        expect(@first_number == @first_number).to be true
        expect(@first_number == @second_number).to be false
      end
 
      it 'should support inequality' do
        expect(@first_number != @first_number).to be false
        expect(@first_number != @second_number).to be true
      end

      it 'should support less than' do
        expect(@first_number < @second_number).to be true
        expect(@second_number < @first_number).to be false
      end

      it 'should support greater than' do
        expect(@first_number > @second_number).to be false
        expect(@second_number > @first_number).to be true
      end

      it 'should support less than or equal to' do
        expect(@first_number <= @first_number).to be true
        expect(@first_number <= @second_number).to be true
        expect(@second_number <= @first_number).to be false
      end

      it 'should support greater than or equal to' do
        expect(@first_number >= @first_number).to be true
        expect(@first_number >= @second_number).to be false
        expect(@second_number >= @first_number).to be true
      end

      it 'should raise errors if not passed a LocationNumeral' do
        expect{@first_number == 1}.to raise_error ArgumentError
        expect{@first_number != 1}.to raise_error ArgumentError
        expect{@first_number >= 1}.to raise_error ArgumentError
        expect{@first_number <= 1}.to raise_error ArgumentError
        expect{@first_number < 1}.to raise_error ArgumentError
        expect{@first_number > 1}.to raise_error ArgumentError
      end
    end
  end
end
