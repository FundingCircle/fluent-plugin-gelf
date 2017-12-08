# frozen_string_literal: true

require "fluent/plugin/formatter"
require "fluent/plugin/gelf_plugin_util"

module Fluent
  module Plugin
    class GelfFormatter < Fluent::Plugin::Formatter
      Fluent::Plugin.register_formatter("gelf", self)
      include Fluent::GelfPluginUtil

      def format(tag, time, record)
        make_gelfentry(tag, time, record)
      end
    end
  end
end
