# ============================================================================
# MULTI-STAGE DOCKERFILE - DigiDekan Frontend (Production)
# ============================================================================
# Stage 1: Build React Application
# Stage 2: Serve with Nginx
# ============================================================================

# ============================================================================
# STAGE 1: BUILD
# ============================================================================
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY root_files/package*.json ./

# Install dependencies
# npm ci ist schneller und deterministischer als npm install
RUN npm ci --only=production=false

# Copy source code
COPY root_files/ ./

# Copy production environment variables
COPY root_files/.env.production .env.production

# Build application
# - TypeScript Compiler prüft Types
# - Vite baut optimiertes Production Bundle
RUN npm run build

# ============================================================================
# STAGE 2: PRODUCTION
# ============================================================================
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built application from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create log directory
RUN mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# ============================================================================
# BUILD & RUN INSTRUCTIONS
# ============================================================================
# Build:
#   docker build -t digidekan-frontend:latest .
#
# Run (standalone):
#   docker run -p 80:80 digidekan-frontend:latest
#
# Run (with docker-compose):
#   siehe docker-compose.production.yml
# ============================================================================
