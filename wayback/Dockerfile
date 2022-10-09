FROM webrecorder/pywb AS builder

RUN apt-get -y update \
  && apt-get -y install git

FROM webrecorder/pywb

COPY --from=builder /usr/bin/git /usr/bin/
# Workaround for: https://github.com/moby/moby/issues/37965
RUN true
COPY ./wayback/startup.sh /

ENTRYPOINT ["/startup.sh"]
