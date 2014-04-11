module SolidUseCase
  module RSpecMatchers

    def be_a_success
      ValidateSuccess.new
    end

    def fail_with(error_name)
      MatchFailure.new(error_name)
    end

    class ValidateSuccess
      def matches?(result)
        @result = result
        @result.is_a? Deterministic::Success
      end

      def failure_message_for_should
        "expected result to be a success\nError & Data:\n    #{@result.value.type} - #{@result.value.inspect}"
      end

      def failure_message_for_should_not
        "expected result to not be a success"
      end
    end

    class MatchFailure

      def initialize(expected_error_name)
        @expected_error_name = expected_error_name
      end

      def matches?(result)
        @result = result
        @is_failure = @result.is_a?(Deterministic::Failure)
        @is_failure && @result.value.type == @expected_error_name
      end

      def failure_message_for_should
        if @is_failure
          "expected result to fail with :#{@expected_error_name} (failed with :#{@result.value.type} instead)"
        else
          "expected result to fail with :#{@expected_error_name} (result was successful instead)"
        end
      end

      def failure_message_for_should_not
        if @is_failure
          "expected result to fail with an error not equal to :#{@expected_error_name}"
        else
          "expected result to fail with an error not equal to :#{@expected_error_name} (result was successful instead)"
        end
      end
    end

  end
end
