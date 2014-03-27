require_relative "./deterministic/version"

warn "WARN: Deterministic is meant to run on Ruby 2+" if RUBY_VERSION.to_f < 2

module Deterministic; end

require_relative './deterministic/monad'
require_relative './deterministic/either/match'
require_relative './deterministic/either'
require_relative './deterministic/either/attempt_all'
require_relative './deterministic/either/success'
require_relative './deterministic/either/failure'
require_relative './deterministic/either/helpers'
require_relative './deterministic/either/clean_context'
