FROM ruby:3.2.2-alpine3.18

RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

WORKDIR /usr/src/app

COPY Gemfile* ./

RUN gem update --system && gem install bundler
RUN bundle check || bundle install --jobs 4

COPY . .
