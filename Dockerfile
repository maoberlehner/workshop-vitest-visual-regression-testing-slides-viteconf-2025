FROM node:22-alpine AS build-base
WORKDIR /app
RUN npm install --global corepack@latest
RUN corepack enable pnpm

FROM build-base AS dependencies
COPY package.json ./
COPY pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

FROM build-base AS build
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
ENV NODE_ENV=production
RUN pnpm build

FROM nginx:1-alpine AS runner
COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY infrastructure/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
