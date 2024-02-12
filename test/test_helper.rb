# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "phlex/slotable"

require "minitest/autorun"

class String
  def join_lines
    gsub(/^\s+/, "").delete("\n")
  end
end
