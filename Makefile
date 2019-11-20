setup: .runner .submitter .datastore .filestore .pdf-generator .service-token-cache

.datastore:
	git clone git@github.com:ministryofjustice/fb-user-datastore.git .datastore

.filestore:
	git clone git@github.com:ministryofjustice/fb-user-filestore.git .filestore

.runner:
	git clone git@github.com:ministryofjustice/fb-runner-node.git .runner

.submitter:
	git clone git@github.com:ministryofjustice/fb-submitter.git .submitter

.pdf-generator:
	git clone git@github.com:ministryofjustice/fb-pdf-generator.git .pdf-generator

.service-token-cache:
	git clone git@github.com:ministryofjustice/fb-service-token-cache.git .service-token-cache

destroy: .runner .submitter .datastore .filestore .pdf-generator .service-token-cache
	docker-compose down

stop:
	docker-compose down

build: stop setup
	echo HEAD > .runner/APP_SHA
	mkdir -p .runner/forms
	cp -r forms/* .runner/forms
	docker-compose build --parallel

serve: build
	docker-compose up -d
	./scripts/wait_for_apps
	./scripts/setup_test_env.sh

spec: serve
	docker-compose run acceptance-tests rspec

clean:
	rm -fr .runner .submitter .datastore .filestore .pdf-generator .service-token-cache
