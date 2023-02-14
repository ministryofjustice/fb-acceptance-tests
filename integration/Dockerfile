FROM ruby:3.1.3-alpine3.16

RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

WORKDIR /usr/src/app

COPY Gemfile* ./

RUN gem update --system && gem install bundler
RUN bundle check || bundle install --jobs 4

COPY . .
