# Builds the safe-wallet-web static export once, so the container does not compile at startup
# (upstream image runs `yarn static-serve` = `next build` + serve on every start).
#
# NEXT_PUBLIC_* values are inlined at build time, so the gateway URL is baked into the image.
#
# The export is plain HTML/JS, so the build stage runs on the build host's native platform
# (fast, no emulation) and only the small serve stage is built for the target platform.

FROM --platform=$BUILDPLATFORM node:24-alpine AS build
RUN apk add --no-cache libc6-compat git python3 py3-pip make g++ libusb-dev eudev-dev linux-headers
WORKDIR /app
COPY . .
WORKDIR /app/apps/web
RUN corepack enable && yarn config set httpTimeout 300000
RUN yarn install --immutable && yarn after-install

ARG GATEWAY_URL
ARG COMMIT_HASH=unknown
ENV NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1 \
    NODE_OPTIONS=--max-old-space-size=8192 \
    NEXT_PUBLIC_IS_PRODUCTION=false \
    NEXT_PUBLIC_SAFE_VERSION=1.4.1 \
    NEXT_PUBLIC_GATEWAY_URL_STAGING=${GATEWAY_URL} \
    NEXT_PUBLIC_COMMIT_HASH=${COMMIT_HASH}
RUN test -n "${GATEWAY_URL}" && yarn build

FROM node:24-alpine
RUN npm install --global serve@14.2.6
WORKDIR /app
COPY --from=build /app/apps/web/out ./out
USER node
EXPOSE 8080
CMD ["serve", "out", "-p", "8080"]
