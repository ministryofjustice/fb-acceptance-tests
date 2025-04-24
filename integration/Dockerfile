FROM cimg/ruby:3.2.2-browsers

RUN apk add build-base bash tzdata chromium-chromedriver chromium zlib-dev xorg-server

WORKDIR /usr/src/app

COPY Gemfile* ./

RUN yarn add puppeteer@24.0.0
RUN npx puppeteer browsers install chrome

RUN gem update --system && gem install bundler
RUN bundle check || bundle install --jobs 4

COPY . .
