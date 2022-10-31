FROM alpine

RUN apk add --no-cache bash curl jq aws-cli postgresql-client && \
    curl -L https://fly.io/install.sh | sh

ENV PATH="/root/.fly/bin:$PATH"

COPY ./pg-dump-to-s3.sh ./entrypoint.sh /

EXPOSE 8080

CMD [ "/entrypoint.sh" ]
