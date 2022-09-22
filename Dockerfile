FROM ghcr.io/linuxserver/baseimage-alpine:3.16

# set version label
ARG BUILD_DATE
ARG VERSION
ARG ENDLESSH_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    jq && \
  echo "**** fetch source code ****" && \
  if [ -z ${ENDLESSH_RELEASE+x} ]; then \
    ENDLESSH_RELEASE=$(curl -sX GET "https://api.github.com/repos/skeeto/endlessh/commits/master" \
      | jq -r '.sha' | cut -c1-8); \
  fi && \
  mkdir -p /app/endlessh && \
  curl -o \
    /tmp/endlessh.tar.gz -L \
    "https://github.com/skeeto/endlessh/archive/${ENDLESSH_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/endlessh.tar.gz -C \
    /app/endlessh --strip-components=1 && \
  echo "**** compile endlessh  ****" && \
  cd /app/endlessh && \
  make && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 2222
