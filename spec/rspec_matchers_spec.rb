require 'spec_helper'

describe 'Custom RSpec Matchers' do
  include SolidUseCase::RSpecMatchers

  class FailCase < SolidUseCase::Command
    def run(error)
      fail(error)
    end
  end

  class SuccessCase < SolidUseCase::Command
    def run(val)
      succeed(val)
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
end
