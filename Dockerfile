FROM ruby:3.1.2

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# taken from ruby's docker hub readme
WORKDIR /usr/src/app

# copy dependency files and install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# copy rest of files. TODO: still need a .dockerignore
COPY . ./

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
