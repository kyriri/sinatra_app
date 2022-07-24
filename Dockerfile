FROM ruby:3.1.2

WORKDIR /project
COPY . /project
RUN bundle install

EXPOSE 9292

CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "9292"]
