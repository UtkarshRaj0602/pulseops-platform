###########################################################
# Stage 1 - Build React Application
###########################################################

FROM node:22-alpine AS builder

WORKDIR /app

# Copy dependency files first for better layer caching
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application source
COPY . .

# Build production assets
RUN npm run build


###########################################################
# Stage 2 - Production Runtime
###########################################################

FROM nginx:1.29-alpine

# Remove default nginx files
RUN rm -rf /usr/share/nginx/html/*

# Copy React build
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]