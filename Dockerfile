# Stage 1: Build the Next.js application
FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package.json and bun.lockb (if exists)
COPY package.json bun.lockb* ./

# Install dependencies using Bun
RUN bun install --frozen-lockfile

# Copy the rest of the application code
COPY . .

# Build the Next.js application
RUN bun run build

# Stage 2: Create the production image
FROM node:18-alpine AS runner

WORKDIR /app
# add curl
RUN apk add --no-cache curl
# Set environment to production
ENV NODE_ENV production

# Copy necessary files from the builder stage
COPY --from=builder /app/next.config.mjs ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Expose the port the app runs on
EXPOSE 3000


CMD ["node", "server.js"]
