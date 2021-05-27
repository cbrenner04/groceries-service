FROM ruby:2.7.3

# taken from ruby's docker hub readme
WORKDIR /usr/src/app

# copy dependency files and install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# copy rest of files. TODO: still need a .dockerignore
COPY . ./

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
