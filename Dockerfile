FROM ruby:3.2.2-alpine AS base

LABEL org.opencontainers.image.source https://github.com/rouge-ruby/dingus

RUN apk add --update --no-cache nodejs \
    && rm -rf /var/cache/apk/*

RUN gem install bundler --no-document --conservative --version 2.4.19

# This stage is responsible for installing gems
FROM base as dependencies

RUN apk add --no-cache build-base

COPY Gemfile Gemfile.lock ./

RUN bundle install --without development --jobs=3 --retry=3

# This stage is what we run the app
FROM base as production

RUN adduser -D app

USER app

WORKDIR /app

COPY --from=dependencies /usr/local/bundle /usr/local/bundle

COPY --chown=app . ./

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "9292"]

# This stage is what
FROM dependencies as development

RUN apk add --update --no-cache bash \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Install development dependencies
RUN bundle install --with development --jobs=3 --retry=3

COPY . ./
