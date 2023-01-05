FROM ruby:latest

RUN mkdir -p /checkout

WORKDIR /checkout

COPY ./checkout/Gemfile Gemfile
COPY ./checkout/Gemfile.lock Gemfile.lock

RUN bundle install

COPY ./checkout ./checkout
