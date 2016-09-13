FROM ruby:2.2.2

RUN apt-get update -qq && apt-get install -y build-essential bzip2 git curl locales

RUN echo 'ru_RU.UTF-8 UTF-8' >> /etc/locale.gen
RUN locale-gen ru_RU.UTF-8
RUN dpkg-reconfigure -fnoninteractive locales
ENV LC_ALL=ru_RU.utf8
ENV LANGUAGE=ru_RU.utf8
RUN update-locale LC_ALL="ru_RU.utf8" LANG="ru_RU.utf8" LANGUAGE="ru_RU"

RUN mkdir -p /app
WORKDIR /app

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN bundle install --jobs 3

ADD . /app

ENV PORT 8080
EXPOSE 8080

CMD bundle exec dashing start -p 8080
