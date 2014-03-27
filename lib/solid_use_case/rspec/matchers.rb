module SolidUseCase
  module RSpecMatchers

    def be_a_success
      ValidateSuccess.new
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

  end
end
