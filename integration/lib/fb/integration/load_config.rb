module Fb
  module Integration
    class LoadConfig
      include Command
      attr_reader :config_file

      def initialize
        @config_file = File.expand_path(
          File.join(File.dirname(__FILE__), '..', '..', '..', 'config.rb')
        )
      end

      def run
        unless File.exist? config_file
          puts "Config file #{config_file} not found. Copying sample"
          run_command('./bin/generate_config')
        end

        load(config_file)
      end
    end
  end
end
