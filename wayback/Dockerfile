ARG PYWB_VERSION=2.10.1
FROM webrecorder/pywb:${PYWB_VERSION} AS builder

RUN apt-get -y update \
  && apt-get -y install git git-lfs

FROM webrecorder/pywb:${PYWB_VERSION}

COPY --from=builder /usr/bin/git /usr/bin/git-lfs /usr/bin/
# Workaround for: https://github.com/moby/moby/issues/37965
RUN true
COPY ./wayback/startup.sh /
COPY ./wayback/config.yaml /webarchive/config.yaml

ENTRYPOINT ["/startup.sh"]
CMD ["wayback"]