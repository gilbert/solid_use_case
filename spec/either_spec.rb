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

    class ShortCircuit
      include SolidUseCase
      steps :first, :second

      def first(inputs)
        fail :jump_out_yo
      end

      def second(inputs)
        throw "Should not reach this point"
      end
    end

    it "doesn't run the next step if a failure occures" do
      expect { ShortCircuit.run }.to_not raise_error
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

  describe 'Helpers' do
    class CheckEachHelper
      include SolidUseCase

      def success_1
        vals = [:x, :y]
        check_each(vals) {|v| v}
      end

      def success_2
        vals = [:x, :y]
        check_each(vals, continue_with: 999) {|v| v}
      end

      def failure_1(goods)
        vals = [5, 10, 0, 15]
        check_each(vals) do |val|
          if val != 0
            goods.push(val)
          else
            fail :zero
          end
        end
      end
    end

    it "checks an array" do
      result = CheckEachHelper.new.success_1
      expect(result).to be_a_success
      expect(result.value).to eq([:x, :y])
    end

    it "continues with a value" do
      result = CheckEachHelper.new.success_2
      expect(result).to be_a_success
      expect(result.value).to eq(999)
    end

    it "fails on first" do
      goods = []
      result = CheckEachHelper.new.failure_1(goods)
      expect(result).to fail_with(:zero)
      expect(goods).to eq([5, 10])
    end
  end

  describe 'Literals' do
    it "creates a success literal" do
      s = SolidUseCase::Either.success(10)
      expect(s).to be_a_success
      expect(s.value).to eq 10
    end

    it "creates a failure literal" do
      f = SolidUseCase::Either.failure(:mock, x: 20)
      expect(f).to_not be_a_success
      expect(f).to fail_with :mock
      expect(f.value[:x]).to eq 20
    end
  end
end
