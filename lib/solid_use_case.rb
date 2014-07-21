require "deterministic"
require "deterministic/core_ext/either"

require "solid_use_case/version"
require 'solid_use_case/base/util.rb'
require 'solid_use_case/base/error_struct.rb'
require 'solid_use_case/base.rb'

module SolidUseCase
end

class Deterministic::Either
  class AttemptAll
    alias :step :let
  end
end
