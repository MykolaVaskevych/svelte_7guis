# Use Bun base image
FROM oven/bun:1 as builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy all source files
COPY . .

# Build the application
RUN bun run build

# Production stage
FROM oven/bun:1-alpine

WORKDIR /app

# Copy built application and package files from builder
COPY --from=builder /app/build build/
COPY --from=builder /app/package.json .
COPY --from=builder /app/bun.lockb* ./

# Install only production dependencies
RUN bun install --production

# Expose port 3000
EXPOSE 3000

# Set environment variables
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

# Start the application using the node adapter
CMD ["bun", "run", "build/index.js"]
