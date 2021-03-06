# Based on https://hub.docker.com/r/monachus/borgmatic/
ARG PYTHON_VERSION=3.8-alpine3.12

FROM python:${PYTHON_VERSION} as builder
ENV PYTHONUNBUFFERED 1
ARG BORGMATIC_VERSION=1.5.12

WORKDIR /wheels
RUN pip3 wheel borgmatic==${BORGMATIC_VERSION}

FROM python:${PYTHON_VERSION}
ARG BORGMATIC_VERSION=1.5.12

COPY --from=builder /wheels /wheels

RUN apk --no-cache add borgbackup openssh-client \
    && pip3 install -f /wheels borgmatic==${BORGMATIC_VERSION} \
    && rm -fr /var/cache/apk/* /wheels /.cache /root/.ssh \
    && ln -s /usr/local/bin/borgmatic /etc/periodic/daily/borgmatic
WORKDIR /
ENTRYPOINT ["crond", "-f", "-d", "1"]

LABEL org.label-schema.version=${BORGMATIC_VERSION}
