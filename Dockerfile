# Written by Artur 'h0m3' Paiva <dr.hoome@gmail.com>
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

FROM alpine:3.17

WORKDIR /app
RUN apk update; apk add git jq bash docker
COPY . /app
RUN chmod +x /app/update-cache.sh

CMD /bin/sh /app/update-cache.sh
