# Install dependencies and build the app
FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
# Fix Webpack + OpenSSL 3 build crash
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN yarn build

# Use production Node.js image to serve
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

CMD ["node_modules/.bin/next", "start", "-p", "4001"]

