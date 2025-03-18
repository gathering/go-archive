FROM webrecorder/pywb AS builder

RUN apt-get -y update \
  && apt-get -y install git git-lfs

FROM webrecorder/pywb

COPY --from=builder /usr/bin/git /usr/bin/git-lfs /usr/bin/
# Workaround for: https://github.com/moby/moby/issues/37965
RUN true
COPY ./wayback/startup.sh /
COPY ./config.yaml /webarchive/config.yaml

ENTRYPOINT ["/startup.sh"]
CMD ["wayback"]