FROM ruby:4.0.9-alpine

RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

WORKDIR /usr/src/app

COPY Gemfile* .ruby-version ./

RUN gem update --system && gem install bundler
RUN bundle check || bundle install --jobs 4

COPY . .
