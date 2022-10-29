FROM ruby:2.7.6-bullseye
RUN apt update
RUN apt install -y nodejs
RUN addgroup app && adduser --ingroup app app
USER app
WORKDIR /app
COPY --chown=app:app . .
RUN bundle install
