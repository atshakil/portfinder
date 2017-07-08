require "test_helper"

class PortfinderTest < Minitest::Test
  def test_assert_module_has_a_version_constant
    refute_nil ::Portfinder::VERSION
  end
end
