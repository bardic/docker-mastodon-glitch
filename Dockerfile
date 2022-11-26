FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.15

LABEL maintainer="judohippo"

ENV RAILS_ENV="production" \
  NODE_ENV="production" \
  PATH="${PATH}:/app/www/bin" \
  OTP_SECRET=precompile_placeholder \
  SECRET_KEY_BASE=precompile_placeholder

RUN \
  apk add -U --upgrade --no-cache \
  ffmpeg \
  file \
  icu-libs \ 
  imagemagick \
  libpq \
  libidn \
  nodejs \
  ruby \
  ruby-bundler \
  yarn && \
  apk add --no-cache --virtual=build-dependencies \
  build-base \
  git \
  g++ \
  gcc \
  icu-dev \
  libidn-dev \    
  libpq-dev \
  libxml2-dev \
  libxslt-dev \
  openssl-dev \
  npm \
  curl \
  ruby-dev \
  unzip && \
  echo "**** install mastodon ****" && \
  gem install bundler && \
  mkdir -p /app/  && \
  cd /app && \
  git clone https://github.com/glitch-soc/mastodon.git /app/www 

WORKDIR /app/www/

RUN \
  bundle config set --local deployment 'true' && \
  bundle config set --local without 'development test' && \
  bundle config set silence_root_warning true && \
  bundle install -j"$(nproc)" && \
  yarn install --pure-lockfile && \
  OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder RAILS_ENV=production rails assets:precompile

RUN \
  cd /app/www/ && \
  echo "**** cleanup ****" && \
  apk del --purge \
  build-dependencies && \
  yarn cache clean && \
  rm -rf 

COPY root/ /

EXPOSE 80 443

VOLUME /config
