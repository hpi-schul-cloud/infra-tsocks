ARG BASE_IMAGE
FROM $BASE_IMAGE AS builder
WORKDIR /tsocks
COPY . .
RUN apk update && apk add build-base && ./configure && make

FROM $BASE_IMAGE
ARG SHLIB
ARG BUILD_BRANCH
ARG BUILD_HASH

LABEL build.stage="release"
LABEL build.branch="${BUILD_BRANCH}"
LABEL build.hash="${BUILD_HASH}"
WORKDIR /tsocks
COPY --from=builder /tsocks .
RUN cp tsocks /usr/bin && cp $SHLIB /usr/lib && cp create-tsocks-config /usr/bin && cp validateconf /usr/bin && ln -s /usr/lib/$SHLIB /usr/lib/libtsocks.so && rm -rf /tsocks


