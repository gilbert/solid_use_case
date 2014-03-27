require 'spec_helper'

describe SolidUseCase::Command do

  describe 'Stepping' do
    class TestA < SolidUseCase::Command
      def run(inputs)
        execute do
          step { step_1(inputs) }
          step {|inputs| step_2(inputs) }
        end
      end

      def step_1(inputs)
        inputs[:number] += 10
        Success(inputs)
      end

      def step_2(inputs)
        inputs[:number] *= 2
        Success(inputs)
      end
    end

    it "pipes one step result to the next step" do
      result = TestA.run(:number => 10)
      expect(result).to be_a_success
    end
  end
end
