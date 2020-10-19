ARG BASE_IMAGE
FROM $BASE_IMAGE AS builder
WORKDIR /tsocks
COPY . .
RUN apk update && apk add build-base && ./configure && make

FROM $BASE_IMAGE
ARG SHLIB
WORKDIR /tsocks
COPY --from=builder /tsocks .
RUN cp tsocks /usr/bin && cp $SHLIB /usr/lib && ln -s /usr/lib/$SHLIB /usr/lib/libtsocks.so && rm -rf /tsocks


