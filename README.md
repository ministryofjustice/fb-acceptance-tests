# Fb Acceptance tests

This is a repo that run all of our acceptance tests.

## Clone

    $ git clone git@github.com:ministryofjustice/fb-acceptance-tests.git

Install dependencies with:

    $ bundle

### Setup all containers

The following command will spin up all form builder platform containers and
services. It takes approximatelly 13 minutes:

    $ make setup

### Run the tests

After all containers are setup, you can run the tests:

    $ make spec

### Setup the tests to run to point to the test environment

    $ make setup-ci && make spec-ci

Emails in CI tests are sent to fb-acceptance-tests@digital.justice.gov.uk.

The following environment variables need to be set in order to authorize against the Google Gmail API:

- GOOGLE_CLIENT_ID
- GOOGLE_CLIENT_SECRET
- GOOGLE_REFRESH_TOKEN

Credentials for interacting with the Gmail API are refreshed each time the test suite is run.

The following environment variables are saved in each platform app on CircleCI:
- SMOKE_TEST_USER
- SMOKE_TEST_PASSWORD
- NEW_RUNNER_ACCEPTANCE_TEST_USER
- NEW_RUNNER_ACCEPTANCE_TEST_PASSWORD

The tests run against forms published to the `test-dev` environment. Currently these are:

Features:

- acceptance-tests-conditional-steps
- acceptance-tests-email-output
- acceptance-tests-json-output
- acceptance-tests-maintenance-mode

There will also be a save and return service to test against but it is not currently published

Components:

- acceptance-tests-autocomplete
- acceptance-tests-checkboxes
- acceptance-tests-conditional-with-upload
- acceptance-tests-date
- acceptance-tests-email-component-form
- acceptance-tests-exit-page
- acceptance-tests-fieldset
- acceptance-tests-number
- acceptance-tests-radios
- acceptance-tests-select
- acceptance-tests-text
- acceptance-tests-textarea
- acceptance-tests-upload

Tests for the JSON output are run against the acceptance-tests-json-output form which sends a encrypted JSON payload the fb-base-adapter. This decrypts it and makes it available to be checked.

## Useful commands

### Start, stop, restart

Commands to start, stop or restart the containers:

    $ make start
    $ make stop
    $ make restart

### Features and Components

It is possible to fun a set of feature or component specs instead of the whole suite:

    $ make feature FEATURE=save_and_return_module

or

    $ make component COMPONENT=autocomplete

Available features:

- conditional_steps
- email_output
- json_output
- maintenance_mode
- save_and_return_module

Available components:

- autocomplete
- checkboxes
- conditionals_and_upload
- date
- email
- fieldset
- number
- radios
- select
- text
- textarea
- upload

## Glossary

The acceptance tests uses a glossary of terms:

1. Platform
2. Services

### Platform

The following are the apps that we have on our platform:

1. Submitter
2. Filestore
3. Datastore
4. Service token cache
5. Pdf generator

You can setup the whole platform with:

```
make platform
```

### Services

The services layer contain N forms with the Runner booting up them.

### Update a specific container

The following command will just rebuild the container:

    $ ./bin/platform --submitter

Or in case of the services:

    $ make services-refresh

## Local

There are times when we made a change and we want to test against our changes.

The following command will install a copy local submitter from your '..' directory,
so please make sure the path is right before running the command:

    $ ls ../fb-submitter # you should have submitter code here
    $ make submitter-local

## Remote

The following command will install a copy of submitter from github and
rebuild the container:

    $ make submitter

This applies for all other containers in the platform (e.g make filestore, etc).

## Configuration file

There is a configuration file which contain information about where to locate
what repos to clone and the container names to build.

This is done automagically but for more details see
integration/config_file.rb.sample.

## Output recorder

There is a script that shows the amount of emails or json requests
send by the submitter, which the output recorder did record. You can run:

    $ ./integration/bin/output-recorder

## Submitter failed jobs

There is a script that shows the amount of jobs that failed to process during
the tests. The tests will output this but you can also run if you like:

    $ ./integration/bin/submitter-failed-jobs

## Updating the tests and running them

Every time you change a spec file you need to run this in order for the
container to be updated:

    $ make integration-refresh && docker-compose run integration bundle exec rspec spec

## Load testing Datastore

Usage:

```
 ./integration/bin/load-test-datastore UUID-of-an-user
```

The argument should be a valid UUID.

1. You will need to grep the private key located in the Procfile.local in order to run the script, and then save the file in integration/bin/private_key. The reason to do this is that we need to generate an access token on Datastore.
2. You need to install apache benchmark (probably that you already have installed - ab in the terminal) and Vegeta load testing (`brew install vegeta`).


## Updating the private and public keys used by the JWT authentication

The acceptance tests use private keys to sign a JWT token when sending requests to apps like the Metadata API. These
public and private keys live in the `formbuilder-saas-test` namespace. Setting them is a bit of a manual process. There
is an example config map file in `/deploy/templates/config_map_example.yaml`. Take a copy of that file and enter in the
require values for the public and private keys. They need to be base64 encoded. Then run:

`kubectl apply -n formbuilder-saas-test -f path/to/config_map.yaml`

You will now be able to see the updated values for those keys:

`kubectl get configmaps -n formbuilder-saas-test  fb-acceptance-tests-config-map -o json`

`ACCEPTANCE_TESTS_PRIVATE_KEY` needs to be set in the environment for the tests to sign each request. See the `fb-deploy`
repo and run the `/bin/get_environment_variables` script.
