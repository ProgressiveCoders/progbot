FROM ruby:2.7.5-bullseye
WORKDIR /app
COPY . .
RUN bundle install
RUN apt update
RUN apt install -y nodejs
RUN rake db:create
RUN addgroup app && adduser -S -G app app
USER app
WORKDIR /app
