#!/bin/sh

echo HEAD > .components/autocomplete/APP_SHA
mkdir -p .components/autocomplete/form
cp -r ./forms/components/autocomplete/* .components/autocomplete/form

echo HEAD > .components/checkboxes/APP_SHA
mkdir -p .components/checkboxes/form
cp -r ./forms/components/checkboxes/* .components/checkboxes/form

echo HEAD > .components/date/APP_SHA
mkdir -p .components/date/form
cp -r ./forms/components/date/* .components/date/form

echo HEAD > .components/email/APP_SHA
mkdir -p .components/email/form
cp -r ./forms/components/email/* .components/email/form

echo HEAD > .components/fieldset/APP_SHA
mkdir -p .components/fieldset/form
cp -r ./forms/components/fieldset/* .components/fieldset/form

echo HEAD > .components/number/APP_SHA
mkdir -p .components/number/form
cp -r ./forms/components/number/* .components/number/form

echo HEAD > .components/radios/APP_SHA
mkdir -p .components/radios/form
cp -r ./forms/components/radios/* .components/radios/form

echo HEAD > .components/select/APP_SHA
mkdir -p .components/select/form
cp -r ./forms/components/select/* .components/select/form

echo HEAD > .components/text/APP_SHA
mkdir -p .components/text/form
cp -r ./forms/components/text/* .components/text/form

echo HEAD > .components/textarea/APP_SHA
mkdir -p .components/textarea/form
cp -r ./forms/components/textarea/* .components/textarea/form

echo HEAD > .components/upload/APP_SHA
mkdir -p .components/upload/form
cp -r ./forms/components/upload/* .components/upload/form

echo HEAD > .components/conditional-with-upload/APP_SHA
mkdir -p .components/conditional-with-upload/form
cp -r ./forms/components/conditional-with-upload/* .components/conditional-with-upload/form
