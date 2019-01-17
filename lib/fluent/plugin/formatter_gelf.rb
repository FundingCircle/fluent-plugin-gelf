# frozen_string_literal: true

require "fluent/plugin/formatter"
require "fluent/plugin/gelf_plugin_util"
require "yajl"

module Fluent
  module Plugin
    class GelfFormatter < Fluent::Plugin::Formatter
      Fluent::Plugin.register_formatter("gelf", self)
      include Fluent::GelfPluginUtil

      def format(tag, time, record)
        Yajl::Encoder.encode(make_gelfentry(tag, time, record))
      end
    end
  end
end
