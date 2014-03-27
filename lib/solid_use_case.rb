# Directly include deterministic source until updated version gets published
require_relative '../vendor/deterministic'

require "solid_use_case/version"
require 'solid_use_case/command/util.rb'
require 'solid_use_case/command/error_struct.rb'
require 'solid_use_case/command.rb'

module SolidUseCase
end

class Deterministic::Either
  class AttemptAll
    alias :step :let
  end
end
