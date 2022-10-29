FROM ruby:2.7.6-bullseye
WORKDIR /app
COPY . .
RUN bundle install
RUN apt update
RUN apt install -y nodejs
RUN addgroup app && adduser --ingroup app app
USER app
WORKDIR /app
