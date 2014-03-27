module SolidUseCase
  class Command
    include Deterministic::Helpers
    include CommandUtil

    def self.run(input_hash={})
      self.new.run(input_hash)
    end

    # # # # # # # # #
    # Monad-related #
    # # # # # # # # #

    def execute(&block)
      attempt_all(self, &block)
    end

    def fail(type, data={})
      data[:type] = type
      Failure(ErrorStruct.new(data))
    end
  end
end
