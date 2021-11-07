FROM webrecorder/pywb AS builder

RUN apt-get -y update \
  && apt-get -y install git

FROM webrecorder/pywb

COPY --from=builder /usr/bin/git /usr/bin/
COPY ./wayback/startup.sh /

ENTRYPOINT ["/startup.sh"]
