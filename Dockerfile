FROM ruby:latest

RUN mkdir -p /checkout

COPY ./checkout/Gemfile Gemfile

RUN bundle install

COPY . /checkout
WORKDIR /checkout
