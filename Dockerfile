FROM ruby:latest

RUN mkdir -p /var/app

COPY ./backend/Gemfile Gemfile

RUN bundle install

COPY ./backend /var/app
WORKDIR /var/app
