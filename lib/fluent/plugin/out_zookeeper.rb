#
# Copyright 2018 CDNetworks Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fluent/plugin/output'
require 'oj'
require 'zookeeper'

module Fluent
  module Plugin
    class ZookeeperOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("zookeeper", self)

      config_param :servers, :string, :default => 'localhost:2181',
                   :desc => <<-DESC
Set zookeeper servers:
<server1_host>:<server1_port>,<server2_host>:<server2_port>,..
DESC
      config_param :path, :string, :default => '/fluent',
                   :desc => "Zookeeper path."
      config_param :type, :string, :default => 'persistent',
                   :desc => "ZNode type."
      config_param :ignore_empty_msg, :bool, :default => false

      def initialize
        super
        @zk = nil
      end

      def init_client(raise_exception = true)
        begin
          @zk = Zookeeper.new(@servers)

          case @type
          when 'ephemeral'
            @zk.create({path: @path, ephemeral: true})
          when 'sequence'
            @zk.create({path: @path, sequence: true})
          else
            # persistent (or anything else)
            @zk.create({path: @path})
          end
          log.info "Connection to Zookeeper service [#@servers] has been initialized"
        rescue Exception => e
          if raise_exception
            raise e
          else
            log.error e
          end
        end
      end

      def configure(conf)
        super

        if @type != 'persistent' && @type != 'ephemeral' && @type != 'sequence'
          log.warn "'type' parameter value is wrong (#@type). Will use default value (persistent))"
          @type = 'persistent'
        end

        @formatter_proc = setup_json_formatter
      end

      def setup_json_formatter
        Oj.default_options = Fluent::DEFAULT_OJ_OPTIONS
        Proc.new { |record| Oj.dump(record) }
      end

      def start
        super
        init_client
      end

      def shutdown
        @zk.delete({path: @path})
        @zk.close
        log.info "Connection to Zookeeper service has been gracefully closed"
        @zk = nil
        super
      end

      def process(tag, es)
        if !@zk.connected?
          init_client(false)
        end

        begin
          es.each do |time, record|
            begin
              data = @formatter_proc.call(record)
              if @ignore_empty_msg && data == "{}"
                log.debug "Skipping empty record"
                next
              end
            rescue StandardError => e
              log.warn "Failed to format record:", :error => e.to_s, :record => record
              next
            end
            @zk.set({path: @path, data: data})
          end
        rescue Exception => e
          log.warn "Exception occurred while sending data: #{e}"
          raise e
        end
      end
    end
  end
end
