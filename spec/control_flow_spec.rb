require 'spec_helper'

describe "Control Flow Helpers" do

  describe '#check_exists' do
    class FloodGate
      include SolidUseCase

      def basic(input)
        check_exists(input).and_then {|x| Success(x * 2) }
      end

      def alias(input)
        maybe_continue(input)
      end

      def custom_error(input, err)
        check_exists(input, err)
      end
    end

    it "stops when the value is nil" do
      result = FloodGate.new.basic(nil)
      expect(result).to fail_with(:not_found)
    end

    it "continues when the value is not nil" do
      result = FloodGate.new.basic(17)
      expect(result).to be_a_success
      expect(result.value).to eq 34
    end

    it "has an alias" do
      result = FloodGate.new.basic(17)
      expect(result).to be_a_success
      expect(result.value).to eq 34
    end

    it "allows a custom error" do
      result = FloodGate.new.custom_error(nil, :my_error)
      expect(result).to fail_with(:my_error)
    end
  end

  describe '#attempt' do
    class Bubble
      include SolidUseCase

      def pop1
        attempt { "pop!" }
      end

      def pop2
        attempt { raise NoMethodError.new("oops") }
      end
    end

    it "succeeds when no exceptions happen" do
      expect(Bubble.new.pop1).to be_a_success
    end

    it "catches exceptions" do
      result = Bubble.new.pop2
      expect(result).to_not be_a_success
      expect(result.value).to be_a NoMethodError
    end
  end

end
