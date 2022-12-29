FROM ruby:latest

RUN mkdir -p /var/app

COPY ./checkout/Gemfile Gemfile

RUN bundle install

COPY . /var/app
WORKDIR /var/app
