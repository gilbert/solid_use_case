module SolidUseCase
  class Base
    include Deterministic::CoreExt::Either
    include BaseUtil

    def self.run(input_hash={})
      self.new.run(input_hash)
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
