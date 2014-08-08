require 'spec_helper'

describe 'Custom RSpec Matchers' do
  include SolidUseCase::RSpecMatchers

  class FailCase
    include SolidUseCase::Composable
    def run(error)
      fail(error)
    end
  end

  class SuccessCase
    include SolidUseCase::Composable
    def run(val)
      continue(val)
    end
  end

  class ExceptionCase
    include SolidUseCase::Composable
    def run(val)
      attempt_all do
        try { raise_exception }
      end
    end

    def raise_exception
      raise NoMethodError.new 'oops'
    end
  end

  describe '#fail_with' do

    it "matches error messages" do
      matcher = fail_with(:xyz)
      expect(matcher.matches? FailCase.run(:xyz)).to eq(true)
      expect(matcher.matches? FailCase.run(:abc)).to eq(false)
    end

    it "does not match successes" do
      matcher = fail_with(:hello)
      expect(matcher.matches? SuccessCase.run).to eq(false)
    end
  end

  describe 'exception handling' do
    it "provides a proper error message for exceptions" do
      matcher = be_a_success
      expect(matcher.matches? ExceptionCase.run).to eq(false)

      expect(matcher.failure_message_for_should).to include('oops')
      expect(matcher.failure_message_for_should).to_not include(
        'deterministic/either/attempt_all.rb',
        'deterministic/core_ext/either.rb',
        'lib/rspec/core/example.rb'
      )
      # Useful for seeing the backtrace output yourself
      # expect(ExceptionCase.run).to be_a_success
    end
  end
end
