# Stage 1: Build
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies (include dev for building)
RUN npm ci

# Copy all source files
COPY . .

# Stage 2: Production
FROM node:18-alpine

# Create a working directory
WORKDIR /app

# Copy only the needed files from build stage
COPY --from=build /app .

# Set environment variable
ENV NODE_ENV=production

# Use non-root user for security
USER node

# Expose app port
EXPOSE 3000

# Add optional healthcheck (recommended for orchestration)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Start the app
CMD ["node", "src/server.js"]
