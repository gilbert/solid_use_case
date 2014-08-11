module SolidUseCase
  module Either
    class ErrorStruct < OpenStruct
      def ==(error_type_symbol)
        self[:type] == error_type_symbol
      end
    end
  end
end
