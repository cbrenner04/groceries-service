FROM ruby:2.7.3

# taken from ruby's docker hub readme. consider if this is what i want
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

# need to add .dockerignore
COPY . .

EXPOSE 3300

CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]
