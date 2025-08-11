# -------- STAGE 1: Build --------
FROM node:lts-alpine as builder

# Enable pnpm
RUN corepack enable pnpm && corepack prepare pnpm@latest --activate

WORKDIR /app/sooperwizer

# Copy full monorepo source
COPY . .

# Install and build only the backend-packing app
RUN pnpm install --frozen-lockfile
RUN pnpm build -F backend-packing

# -------- STAGE 2: Runtime --------
FROM node:lts-alpine

# Enable pnpm (if needed by `npm run` scripts)
RUN corepack enable pnpm && corepack prepare pnpm@latest --activate

WORKDIR /app/sooperwizer

# Copy built app and only needed files from builder
COPY --from=builder /app/sooperwizer/apps/backend-packing/build ./apps/backend-packing/build
COPY --from=builder /app/sooperwizer/shared-env/backend/.env.production ./shared-env/backend/.env.production
COPY --from=builder /app/sooperwizer/apps/backend-packing/package.json ./apps/backend-packing/package.json

# Set working dir and start
WORKDIR /app/sooperwizer/apps/backend-packing\
CMD ["npm", "run", "start:production"]

