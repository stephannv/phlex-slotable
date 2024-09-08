# frozen_string_literal: true

require "test_helper"

class Phlex::TestVersion < Minitest::Test
  def test_version
    refute_nil Phlex::Slotable::VERSION
  end
end
