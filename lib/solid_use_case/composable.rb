module SolidUseCase
  module Composable

    def self.included(includer)
      includer.send :include, Deterministic::CoreExt::Either
      includer.extend ClassMethods
    end

    def run(inputs)
      steps = self.class.instance_variable_get("@__steps").clone
      result = Success(inputs)
      return result unless steps

      while steps.count > 0
        next_step = steps.shift

        if next_step.is_a?(Class) && (next_step.respond_to? :composable?) && next_step.composable?
          subresult = next_step.run(result.value)
        elsif next_step.is_a?(Symbol)
          subresult = self.send(next_step, result.value)
        else
          raise "Invalid step type: #{next_step.inspect}"
        end

        result = result.and(subresult)
      end

      result
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

    def fail(type, data={})
      data[:type] = type
      Failure(ErrorStruct.new(data))
    end

    alias :maybe_continue :check_exists
    alias :continue :Success
  end
end
