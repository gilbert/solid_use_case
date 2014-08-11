require "deterministic"
require "deterministic/core_ext/either"

require "solid_use_case/version"
require 'solid_use_case/either/class_methods.rb'
require 'solid_use_case/either/error_struct.rb'
require 'solid_use_case/either/util.rb'
require 'solid_use_case/either.rb'

module SolidUseCase
  def self.included(includer)
    includer.send :include, Deterministic::CoreExt::Either
    includer.send :include, Either
    includer.extend Either::ClassMethods
  end
end

class Deterministic::Either
  class AttemptAll
    alias :step :let
  end
end
