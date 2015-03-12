require 'helper'

class SnmpTrapInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag alert.cloudwatch.raw.FPS
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchTransformOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 'alert.cloudwatch.out', d.instance.tag
  end
end