FROM alpine:3.17

WORKDIR /app
RUN apk update; apk add git jq bash docker
COPY . /app
RUN chmod +x /app/update-cache.sh

CMD /bin/sh /app/update-cache.sh
