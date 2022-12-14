# frozen_string_literal: true

require "wafris-ruby"

require "minitest/autorun"
require "minitest/spec"

module Wafris
  module Test
  end
end

Minitest::Test.include(Wafris::Test)
