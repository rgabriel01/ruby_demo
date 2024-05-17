# syntax = docker/dockerfile:1

ARG RUBY_VERSION=2.7.0
ARG DEFAULT_PORT 3000

# ruby image from dockerhub
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Rails app lives here
# rails
#   /app
#   /bin
#   /db
#   /lib
WORKDIR /rails

# Set development environment
ENV RAILS_ENV="development"
ENV BUNDLE_WITHOUT=""

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libvips pkg-config

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code to /rails
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-dev-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000

# for those running WSL
# this instructs docker to use 0.0.0.0 as its IP address; able to use localhost on browser
#CMD ["./bin/rails", "server", "-b", "0.0.0.0"]

# this instructs docker to use 0.0.0.0 as its IP address; so that we are able to use localhost on browser
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]


# to run do
# -f specifies which docker file we are building on
# -t tags/names the image
# . just states that we are building under the same current directory
# docker build -f dev.dockerfile -t rails_demo .
