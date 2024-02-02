platform-clone:
	./integration/bin/platform --install --all --no-build

# platform clone is needed because docker compose read the docker-compose.yml
# and complains that the context for other containers doesn't exist
services: platform-clone
	./integration/bin/runner --remote
	$(MAKE) services-post-install
	$(MAKE) services-build

services-post-install:
	cp Procfil* .runner
	cp Dockerfile.forms .runner
	cp Gemfile .runner/Gemfile
	cp -R ./integration/ .runner/integration/
	cp -R forms/ .runner/forms/
	echo HEAD > .runner/APP_SHA

services-build:
	docker-compose up -d --build services

services-post-build:
	./integration/bin/wait_for_services

services-local:
	./integration/bin/runner --local
	$(MAKE) services-post-install
	$(MAKE) services-build
	$(MAKE) services-post-build

platform:
	./integration/bin/platform --submitter --filestore --datastore --pdf-generator --service-token-cache
	$(MAKE) platform-post-install

## Everything in one. Better for performance.
platform-local:
	./integration/bin/platform --install --submitter-local --filestore-local --datastore-local --pdf-generator-local --service-token-cache-local --base-adapter-local
	$(MAKE) platform-post-install

submitter-local:
	./integration/bin/platform --install --submitter-local

datastore-local:
	./integration/bin/platform --install --datastore-local

pdf-generator-local:
	./integration/bin/platform --install --pdf-generator-local

filestore-local:
	./integration/bin/platform --install --filestore-local
	$(MAKE) platform-post-install

service-token-cache-local:
	./integration/bin/platform --install --service-token-cache-local
	$(MAKE) platform-post-install

submitter-refresh:
	./integration/bin/platform --update submitter --no-build

datastore-refresh:
	./integration/bin/platform --update datastore --no-build

pdf-generator-referesh:
	./integration/bin/platform --update pdf-generator --no-build

filestore-refresh:
	./integration/bin/platform --update filestore --no-build

service-token-cache-refresh:
	./integration/bin/platform --update service-token-cache --no-build

platform-post-install:
	./integration/bin/wait_for_platform
	./integration/bin/post_install

services-refresh:
	docker-compose up -d --build services
	$(MAKE) services-post-build

local-env-vars:
	cp integration/tests.env.local integration/tests.env

integration-refresh:
	docker-compose up -d --build integration

prepare: local-env-vars integration-refresh services-post-build

## Extra experimental
ci-google-envars:
	echo "GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}" >> ./integration/tests.env
	echo "GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}" >> ./integration/tests.env
	echo "GOOGLE_REFRESH_TOKEN='${GOOGLE_REFRESH_TOKEN}'" >> ./integration/tests.env

## Experimental ##
ci-env-vars:
	cp integration/tests.env.ci integration/tests.env

## Experimental ##
start-ci: ci-env-vars ci-google-envars new-runner-acceptance-test-env-vars
	docker-compose -f docker-compose.ci.yml up -d --build integration_ci

setup-ci: start-ci

setup: services platform prepare

setup-local: services-local platform-local prepare

start:
	docker-compose up -d
	$(MAKE) platform-post-install
	$(MAKE) services-post-build

stop:
	docker-compose down

restart:
	$(MAKE) stop
	$(MAKE) start

spec:
	docker-compose run integration bundle exec rspec spec

feature:
ifndef FEATURE
	$(error FEATURE is required)
endif
	docker-compose run integration bundle exec rspec spec/features/$(FEATURE)_spec.rb

component:
ifndef COMPONENT
	$(error COMPONENT is required)
endif
	docker-compose run integration bundle exec rspec spec/components/$(COMPONENT)_spec.rb

## Experimental ##
spec-ci:
	docker-compose -f docker-compose.ci.yml run --rm integration_ci \
	bundle exec rspec $(or $(SPEC_DIR),spec/features/v2) --fail-fast

## Clears out emails older than 24 hours from the gmail inbox that receives test submissions
clear-emails:
	ruby ./scripts/clear_emails.rb

smoke-test-env-vars:
	echo "SMOKE_TEST_USER=${SMOKE_TEST_USER}" >> ./integration/tests.env
	echo "SMOKE_TEST_PASSWORD=${SMOKE_TEST_PASSWORD}" >> ./integration/tests.env

smoke-tests: ci-env-vars smoke-test-env-vars ci-google-envars
	docker-compose -f docker-compose.ci.yml up -d --build integration_ci
	docker-compose -f docker-compose.ci.yml run integration_ci bundle exec rspec smoke_tests/form_spec.rb

smoke-tests-v2: ci-env-vars smoke-test-env-vars ci-google-envars
	docker-compose -f docker-compose.ci.yml up -d --build integration_ci
	docker-compose -f docker-compose.ci.yml run integration_ci bundle exec rspec smoke_tests_v2/form_spec.rb

new-runner-acceptance-test-env-vars:
	echo "NEW_RUNNER_ACCEPTANCE_TEST_USER=${NEW_RUNNER_ACCEPTANCE_TEST_USER}" >> ./integration/tests.env
	echo "NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD=${NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD}" >> ./integration/tests.env
