# frozen_string_literal: true

require "oj"
require "date"

module Fluent
  module GelfPluginUtil
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

    def merge_inner_json(record, key)
      return record unless record[key]
      json = Oj.load(record[key].strip)
      return record unless json
      json["host"] = record["host"] # preserve host
      record.delete(key)
      record.merge(json)
    rescue Oj::ParseError
      record
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def make_gelfentry(tag, time, record)
      record = merge_inner_json(record, "message")
      record = merge_inner_json(record, "log")
      gelfentry = {}
      gelfentry["timestamp"] = if defined?(Fluent::EventTime) && time.is_a?(Fluent::EventTime)
                                 time.sec + (time.nsec.to_f / 1_000_000_000).round(3)
                               else
                                 time
                               end

      gelfentry["_fluentd_tag"] = tag

      record.each_pair do |k, v| # rubocop:disable Metrics/BlockLength
        case k
        when "timestamp"
          gelfentry["timestamp"] = if v.is_a?(Integer) || v.is_a?(Float)
                                     v
                                   else
                                     begin
                                       (DateTime.parse(v).strftime("%Q").to_f / 1_000).round(3)
                                     rescue ArgumentError
                                       v
                                     end
                                   end
        when "msec" then
          if time.is_a?(Integer) && record["timestamp"].nil?
            gelfentry["timestamp"] = "#{time}.#{v}".to_f
          else
            gelfentry["_msec"] = v
          end
        when "level"
          gelfentry["level"] = if v.is_a?(Integer)
                                 v
                               else
                                 level = LEVEL_MAPPING.keys.find { |l| v.downcase =~ /#{l}/ }
                                 level.nil? ? v : LEVEL_MAPPING[level]
                               end
        when "source_realtime_timestamp" then gelfentry["timestamp"] = (v.to_f / 1_000_000).round(3)
        when "host", "hostname" then gelfentry["host"] = v.to_s
        when "priority" then gelfentry["level"] = v.to_i
        when "syslog_facility" then gelfentry["facility"] = SYSLOG_FACILITY[v]
        when "short_message", "version", "full_message", "facility", "file", "line" then gelfentry[k] = v
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
      end

      if gelfentry["level"].nil?
        level = LEVEL_MAPPING.keys.find { |k| tag.downcase =~ /\.#{k}/ }
        gelfentry["level"] = level.nil? ? 6 : LEVEL_MAPPING[level]
      end

      gelfentry
    end
  end
end
