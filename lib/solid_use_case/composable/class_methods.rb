module SolidUseCase
  module Composable
    module ClassMethods

      def run(input_hash={})
        self.new.run(input_hash)
      end

      def steps(*args)
        @__steps ||= []
        @__steps += args
      end

      def composable?
        true
      end

    end
  end
end