# fluent-plugin-zookeeper

[Fluentd](https://fluentd.org/) output plugin for Apache Zookeeper.

## Installation

### RubyGems

```
$ gem install fluent-plugin-zookeeper
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-zookeeper"
```

And then execute:

```
$ bundle
```

## Configuration

The following is an example plugin configuration for Fluentd health monitoring:

    <source>
      @type exec
      command echo -n '{"message": "heartbeat"}'
      tag heartbeat
      format json
      run_interval 10s
    </source>

    <match heartbeat.**>
      @type copy
      <store>
        @type zookeeper
        servers <zookeeper_server1>:<zookeeper_port1>,<zookeeper_server2>:<zookeeper_port2>,<zookeeper_server3>:<zookeeper_port3>,...
        path "/fluent/#{Socket.gethostname}_persistent"
      </store>
      <store>
        @type zookeeper
        servers <zookeeper_server1>:<zookeeper_port1>,<zookeeper_server2>:<zookeeper_port2>,<zookeeper_server3>:<zookeeper_port3>,...
        path "/fluent/#{Socket.gethostname}_ephemeral"
        type ephemeral
      </store>
    </match>

Configuration above uses in_exec plugin as a heartbeat message generator. During normal operation two znodes will exist on Zookeeper for a host running Fluentd: persistent and ephemeral. Ephemeral znode is deleted automatically if fluentd has a "bad health" or network/connection problem. So, having only one persistent znode is a signal to trigger alert.

## TODO

Let me know if support for buffered output mode and older versions of fluentd is necessary.
