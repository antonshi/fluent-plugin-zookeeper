require "helper"
require "fluent/plugin/out_zookeeper.rb"

class ZookeeperOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    servers localhost:2181
    path /fluent_test
    type wrongtype
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::ZookeeperOutput).configure(conf)
  end

  def test_configure
    assert_nothing_raised(Fluent::ConfigError) {
      create_driver(CONFIG)
    }

    d = create_driver(CONFIG)
    assert_equal 'localhost:2181', d.instance.servers
    assert_equal '/fluent_test', d.instance.path
    assert_equal 'persistent', d.instance.type
  end

  def test_process
    d = create_driver(CONFIG)
    d.run(default_tag: "test") do
      d.feed({ "message" => "Test message" })
    end
  end
end
