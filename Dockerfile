FROM ruby:alpine

ENV TZ       utc
ENV LANG     en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_ALL   en_US.UTF-8

RUN set -ex \
 && apk upgrade --no-cache \
 && apk add \
        bash \
        ca-certificates \
        curl \
        git \
        less \
        libressl \
        tzdata \
        vim \
        wget \
        postgresql-dev \
 && apk add --virtual build-dependencies \
        build-base \
 && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
 && ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
 && gem update --system --quiet \
 && gem install bundler \
 && gem cleanup \
 && addgroup -g 1234 app \
 && adduser -D -u 1234 -G app app

COPY --chown=app:app . /src

WORKDIR /src

RUN set -eux \
 && bundle install --frozen --jobs 4 --retry 4 --without development test \
 && apk del build-dependencies \
 && rm -rf /usr/local/bundle/cache

USER app

CMD [ ./bin/worker ]
