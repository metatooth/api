# Use the official Ruby image.
# https://hub.docker.com/_/ruby
FROM ruby:2.5

# Install production dependencies.
WORKDIR /usr/src/app
COPY Gemfile Gemfile.lock ./
ENV BUNDLE_FROZEN true
RUN bundle install

# Copy local code to the container image.
COPY . .

EXPOSE 5000
# Run the web service on container startup.
ENV PROJECT_ID toptal-test-project-9ff35
ENV GOOGLE_APPLICATION_CREDENTIALS /usr/src/app/toptal-test-project-10fd92626b7f.json
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "5000"]