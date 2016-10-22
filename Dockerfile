FROM ruby:2.3.1
MAINTAINER Marko Lovic <markolovic33@gmail.com>

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client

ENV APP_HOME /mtb-scrape-scraper
ENV RACK_ENV production
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

EXPOSE 4567
