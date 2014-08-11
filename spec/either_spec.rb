require 'spec_helper'

describe SolidUseCase::Either do

  describe 'Stepping' do
    class GiantSteps
      include SolidUseCase

      def run(inputs)
        attempt_all do
          step { step_1(inputs) }
          step {|inputs| step_2(inputs) }
        end
      end

      def step_1(inputs)
        inputs[:number] += 10
        continue(inputs)
      end

      def step_2(inputs)
        inputs[:number] *= 2
        continue(inputs)
      end
    end

    it "pipes one step result to the next step" do
      result = GiantSteps.run(:number => 10)
      expect(result).to be_a_success
      expect(result.value[:number]).to eq(40)
    end
  end


  describe 'Stepping DSL' do
    class GiantStepsDSL
      include SolidUseCase

      steps :step_1, :step_2

      def step_1(inputs)
        inputs[:number] += 10
        continue(inputs)
      end

      def step_2(inputs)
        inputs[:number] *= 2
        continue(inputs)
      end
    end

    it "pipes one step result to the next step" do
      result = GiantStepsDSL.run(:number => 10)
      expect(result).to be_a_success
      expect(result.value[:number]).to eq(40)
    end

    it "can run multiple times" do
      result = GiantStepsDSL.run(:number => 10)
      result = GiantStepsDSL.run(:number => 10)
      expect(result).to be_a_success
      expect(result.value[:number]).to eq(40)
    end

    class SubStep
      include SolidUseCase
      steps GiantStepsDSL, :last_step

      def last_step(inputs)
        inputs[:number] += 1
        continue(inputs[:number])
      end
    end

    it "pipes one step result to the next step" do
      result = SubStep.run(:number => 10)
      expect(result).to be_a_success
      expect(result.value).to eq(41)
    end
  end


  describe 'Failure Matching' do
    class FailureMatch
      include SolidUseCase

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

      expect(result.value).to be_a SolidUseCase::Either::ErrorStruct
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
