require 'spec_helper'

describe SolidUseCase::Base do

  describe 'Stepping' do
    class GiantSteps < SolidUseCase::Base
      def run(inputs)
        attempt_all do
          step { step_1(inputs) }
          step {|inputs| step_2(inputs) }
        end
      end

      def step_1(inputs)
        inputs[:number] += 10
        next_step(inputs)
      end

      def step_2(inputs)
        inputs[:number] *= 2
        succeed(inputs)
      end
    end

    it "pipes one step result to the next step" do
      result = GiantSteps.run(:number => 10)
      expect(result).to be_a_success
      expect(result.value[:number]).to eq(40)
    end
  end


  describe 'Failure Matching' do
    class FailureMatch < SolidUseCase::Base
      def run(inputs)
        attempt_all do
          step { fail_it(inputs) }
        end
      end

      def fail_it(inputs)
        error_sym = inputs[:fail_with]
        fail(error_sym)
      end
    end

    it "pattern matches" do
      result = FailureMatch.run(:fail_with => :abc)
      # Custom RSpec matcher
      expect(result).to_not be_a_success

      expect(result.value).to be_a SolidUseCase::ErrorStruct
      expect(result.value.type).to eq :abc

      matched = false
      result.match do
        success { raise StandardError.new "We shouldn't get here" }
        failure(:xyz) { raise StandardError.new "We shouldn't get here" }
        failure(:abc) { matched = true }
        failure { raise StandardError.new "We shouldn't get here" }
      end
      expect(matched).to eq true
    end
  end
end
