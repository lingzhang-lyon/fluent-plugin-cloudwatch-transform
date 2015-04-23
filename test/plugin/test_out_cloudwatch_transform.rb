require 'helper'

class CloudWatchTransOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    tag alert.cloudwatch.raw.region1-AZ1.Form & Printing Services (FPS)."http://testurl.com"
    out_tag  alert.processed.cloudwatch
    state_type file
    state_file cloudwatch.yaml
    state_tag cloudwatch
    name_for_origin_key event_name
    name_for_origin_value value
    <tag_infos>
      region_and_AZ 3
      application_name 4
      runbook_url 5
    </tag_infos>
  ]

  def create_driver(conf=CONFIG)
    Fluent::Test::InputTestDriver.new(Fluent::CloudwatchTransformOutput).configure(conf)
  end

  def test_configure
    d = create_driver
    assert_equal 'alert.processed.cloudwatch', d.instance.out_tag
  end
end