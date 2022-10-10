FROM ruby:2.7.5-alpine3.15
RUN addgroup app && adduser -S -G app app
USER app
WORKDIR /app
RUN bundle install
RUN rake db:create