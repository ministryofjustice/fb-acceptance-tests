FROM ruby:3.0.0-alpine

RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

WORKDIR /usr/src/app

COPY Gemfile* ./
RUN gem update --system && gem install bundler
RUN bundle check || BUNDLE_JOBS=4 bundle install

COPY . .
