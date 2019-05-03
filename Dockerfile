# = debianのpostgresql-clientに問題がある
# * CircleCIの記事
# ** https://support.circleci.com/hc/ja/articles/360003953613-Docker-%E3%81%AB-postgresql-client-9-6-%E3%82%92%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E3%81%99%E3%82%8B%E9%9A%9B%E3%81%AE%E3%82%A8%E3%83%A9%E3%83%BC
# * gnupg2はapt-key addのため

FROM ruby:2.6.3-slim-stretch as builder
WORKDIR /app
RUN apt-get update && apt-get install -y wget gnupg2 curl
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' | tee /etc/apt/sources.list.d/pgdg.list && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
# yarn用
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
  apt-get install -y build-essential patch ruby-dev nodejs yarn libpq-dev postgresql-client
COPY Gemfile* ./
RUN gem uninstall bundler && gem install bundler -N -v=1.17.3 && bundle install -j4 --path vendor/bundle
COPY . ./

# マルチステージビルドでdeploy用
FROM ruby:2.6.3-slim-stretch as production
ENV RAILS_ENV=production RACK_ENV=production
WORKDIR /app
RUN apt-get update && apt-get install -y wget gnupg2 curl
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' | tee /etc/apt/sources.list.d/pgdg.list && \
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
# yarn用
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && \
  apt-get install -y postgresql-client nodejs yarn && \
  apt-get autoclean && apt-get clean
COPY . ./
COPY --from=builder /app/vendor/bundle /app/vendor/bundle
RUN gem uninstall bundler && gem install bundler -N -v=1.17.3 && \
  yarn install && \
  bundle install --no-cache -j4 --path=vendor/bundle --without development test && \
  bundle clean
