FROM ruby:3.1.3-alpine3.16

ARG UID=1001

RUN apk add build-base bash libcurl

RUN addgroup -g ${UID} -S appgroup && \
  adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app

RUN chown appuser:appgroup /app

COPY --chown=appuser:appgroup Gemfile Gemfile.lock ./

ENV BUNDLER_VERSION 2.3.18
RUN gem install bundler

ARG BUNDLE_ARGS='--jobs 4 --without test development'
RUN bundle install --no-cache ${BUNDLE_ARGS}

COPY --chown=appuser:appgroup . .

ENV APP_PORT 3000
EXPOSE $APP_PORT

USER ${UID}

CMD APP_ENV=production bundle exec ruby app.rb -p ${APP_PORT}
