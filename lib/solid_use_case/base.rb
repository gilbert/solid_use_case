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
        result = result.and self.send(steps.shift, result.value)
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
