module SolidUseCase
  class Base
    include Deterministic::CoreExt::Either
    include BaseUtil

    def self.run(input_hash={})
      self.new.run(input_hash)
    end

    def self.steps(*args)
      @__steps ||= []
      @__steps += args
    end

    def run(inputs)
      steps = self.class.instance_variable_get("@__steps").clone
      result = Success(inputs)
      return result unless steps

      while steps.count > 0
        next_step = steps.shift

        if next_step.is_a?(Class) && (next_step < SolidUseCase::Base)
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

    def fail(type, data={})
      data[:type] = type
      Failure(ErrorStruct.new(data))
    end

    alias :continue :Success
  end
end
