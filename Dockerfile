# Dockerfile

FROM ruby:2.6.10

WORKDIR /app
COPY . /app

EXPOSE 4567

CMD ruby /app/index.rb


