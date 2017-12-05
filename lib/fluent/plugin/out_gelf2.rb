# frozen_string_literal: true

require "fluent/plugin/output"

SYSLOG_FACILITY = {
  "0" => "kern",
  "1" => "user",
  "2" => "mail",
  "3" => "daemon",
  "4" => "auth",
  "5" => "syslog",
  "6" => "lpr",
  "7" => "news",
  "8" => "uucp",
  "9" => "cron",
  "10" => "authpriv",
  "16" => "local0",
  "17" => "local1",
  "18" => "local2",
  "19" => "local3",
  "20" => "local4",
  "21" => "local5",
  "22" => "local6",
  "23" => "local7",
}.freeze

LEVEL_MAPPING = {
  "error" => 3,
  "warn" => 4,
  "info" => 6,
  "debug" => 7,
}.freeze

module Fluent
  module Plugin
    class Gelf2Output < Fluent::Plugin::Output
      Fluent::Plugin.register_output("gelf2", self)

      config_param :host, :string, default: nil
      config_param :port, :integer, default: 12_201

      def configure(conf)
        super
        raise ConfigError, "'host' parameter is required" unless conf.key?("host")
      end

      def start
        super
      end

      def shutdown
        super
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      def format(tag, time, record)
        gelfentry = {}
        gelfentry["timestamp"] = if defined?(Fluent::EventTime) && time.is_a?(Fluent::EventTime)
                                   time.sec + (time.nsec.to_f / 1_000_000_000).round(3)
                                 else
                                   time
                                 end

        gelfentry["_fluentd_tag"] = tag

        record.each_pair do |k, v|
          case k
          when "timestamp" then gelfentry["timestamp"] = v
          when "msec" then
            if time.is_a?(Integer) && record["timestamp"].nil?
              gelfentry["timestamp"] = "#{time}.#{v}".to_f
            else
              gelfentry["_msec"] = v
            end
          when "source_realtime_timestamp" then gelfentry["timestamp"] = (v.to_f / 1_000_000).round(3)
          when "host", "hostname" then gelfentry["host"] = v.to_s
          when "priority" then gelfentry["level"] = v.to_i
          when "syslog_facility" then gelfentry["facility"] = SYSLOG_FACILITY[v]
          when "short_message", "version", "full_message", "facility", "file", "line", "level" then gelfentry[k] = v
          else
            k.to_s.start_with?("_") ? gelfentry[k] = v : gelfentry["_#{k}"] = v
          end
        end

        if gelfentry["short_message"].nil? || gelfentry["short_message"].to_s.empty?
          gelfentry["short_message"] = if gelfentry.key?("_message") && !gelfentry["_message"].to_s.empty?
                                         gelfentry.delete("_message")
                                       elsif gelfentry.key?("_log") && !gelfentry["_log"].to_s.empty?
                                         gelfentry.delete("_log")
                                       else
                                         "(no message)"
                                       end
        else
          gelfentry.delete("_log")
        end

        if gelfentry["level"].nil?
          level = LEVEL_MAPPING.keys.select { |k| tag =~ /\.#{k}/ }.first
          gelfentry["level"] = LEVEL_MAPPING[level] if level
        end

        gelfentry.to_msgpack
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

      def write(chunk) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        records = []
        chunk.msgpack_each do |record|
          records.push JSON.dump(record) + "\0" # Message delimited by null char
        end

        log.debug "establishing connection with GrayLog"
        socket = TCPSocket.new(@host, @port)

        begin
          log.debug "sending #{records.count} records in batch"
          socket.write(records.join)
        ensure
          log.debug "closing connection with GrayLog"
          socket.close
        end
      end

      def formatted_to_msgpack_binary
        true
      end

      def multi_workers_ready?
        true
      end
    end
  end
end
