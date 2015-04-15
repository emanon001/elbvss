FROM ruby:2.1.3
MAINTAINER emanon001 <emanon001@gmail.com>

# bundle install (cache)
WORKDIR /tmp
ADD ./Gemfile /tmp/
ADD ./Gemfile.lock /tmp/
RUN bundle install

RUN mkdir -p /var/app/
ADD ./init.rb /var/app/
ADD ./app.rb /var/app/
ADD ./lib /var/app/

WORKDIR /var/app
ADD ./docker-entry-point.sh /var/app/
ENTRYPOINT ["/var/app/docker-entry-point.sh"]
