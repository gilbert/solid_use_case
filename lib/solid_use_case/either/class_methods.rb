module SolidUseCase
  module Either
    module ClassMethods

      def run(input_hash={})
        self.new.run(input_hash)
      end

      def steps(*args)
        @__steps ||= []
        @__steps += args
      end

      def can_run_either?
        true
      end

    end
  end
end