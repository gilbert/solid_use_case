module SolidUseCase
  module Either

    def run(inputs)
      steps = self.class.instance_variable_get("@__steps").clone
      current_result = Success(inputs)
      return current_result unless steps

      while steps.count > 0
        next_step = steps.shift

        current_result = current_result.and_then do
          if next_step.is_a?(Class) && (next_step.respond_to? :can_run_either?) && next_step.can_run_either?
            next_step.run(current_result.value)
          elsif next_step.is_a?(Symbol)
            self.send(next_step, current_result.value)
          else
            raise "Invalid step type: #{next_step.inspect}"
          end
        end
      end

      current_result
    end

    # # # # # #
    # Helpers #
    # # # # # #

    def check_exists(val, error=:not_found)
      if val.nil?
        fail(error)
      else
        continue(val)
      end
    end

    def attempt
      attempt_all do
        try { yield }
      end
    end

    def catch(required, *exceptions)
      exceptions << required
      result = attempt_all do
        try { yield }
      end
      if result.is_a?(Failure) && exceptions.any?
        raise result.value unless exceptions.include?(result.value)
      end
    end

    def fail(type, data={})
      data[:type] = type
      Failure(ErrorStruct.new(data))
    end

    alias :maybe_continue :check_exists
    alias :continue :Success
  end
end
