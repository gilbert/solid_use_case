require "deterministic"
require "deterministic/core_ext/either"

require "solid_use_case/version"
require 'solid_use_case/composable/class_methods.rb'
require 'solid_use_case/composable/error_struct.rb'
require 'solid_use_case/composable/util.rb'
require 'solid_use_case/composable.rb'

module SolidUseCase
end

class Deterministic::Either
  class AttemptAll
    alias :step :let
  end
end
