module Fb
  module Integration
    class CLI
      attr_accessor :options

      def initialize(args)
        @options = Options.new(args).parse
      end

      def run
        if @options.setup_repositories.present?
          setup_repositories if @options.install?
          build_containers unless @options.no_build?
          update_containers if @options.update?
        end
      end

      private

      def setup_repositories
        @options.setup_repositories.each do |setup_repository|
          repository = Fb::Integration.find_repository(setup_repository[:name])
          setup_type = setup_repository[:type] || repository.setup_type

          CleanupRepository.new(repository: repository).execute
          SetupRepository.new(
            repository: repository
          ).execute(setup_type: setup_type)
        end
      end

      def build_containers
        repositories = @options.setup_repositories.map do |setup_repository|
          Fb::Integration.find_repository(setup_repository[:name])
        end

        DockerCompose.new(repositories).execute
      end

      def update_containers
        repositories = @options.setup_repositories.map do |setup_repository|
          Fb::Integration.find_repository(setup_repository[:name])
        end

        DockerCompose.new(repositories).update_containers
      end

      def post_install
        SpecificPostInstall.new.execute
      end
    end
  end
end
