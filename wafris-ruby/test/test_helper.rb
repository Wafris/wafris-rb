# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "wafris-ruby"

require "minitest/autorun"
require "minitest/spec"

module Wafris
  module Test
  end

end

Minitest::Test.include(Wafris::Test)