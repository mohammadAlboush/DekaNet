#!/bin/bash
# =============================================================================
# DigiDekan Deployment Script
# =============================================================================
#
# Usage:
#   ./deploy.sh [--build] [--migrate] [--restart]
#
# Prerequisites:
#   1. Docker and Docker Compose installed
#   2. .env.production file exists in project root
#   3. Git repository configured
#
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="${PROJECT_DIR}/docker"
BACKEND_DIR="${PROJECT_DIR}/backend"
COMPOSE_FILE="${DOCKER_DIR}/docker-compose.production.yml"

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}DigiDekan Deployment Script${NC}"
echo -e "${GREEN}============================================${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Docker is not running!${NC}"
    exit 1
fi

# Parse arguments
BUILD=false
MIGRATE=false
RESTART=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD=true
            shift
            ;;
        --migrate)
            MIGRATE=true
            shift
            ;;
        --restart)
            RESTART=true
            shift
            ;;
        *)
            echo -e "${YELLOW}Unknown option: $1${NC}"
            shift
            ;;
    esac
done

# Step 1: Pull latest code
echo -e "\n${YELLOW}[1/6] Pulling latest code...${NC}"
cd "${PROJECT_DIR}"
git pull origin main

# Step 2: Check for .env.production
echo -e "\n${YELLOW}[2/6] Checking environment files...${NC}"
if [ ! -f "${PROJECT_DIR}/.env.production" ]; then
    echo -e "${RED}ERROR: .env.production not found!${NC}"
    echo "Please create .env.production with production settings."
    echo "Template: cp .env.example .env.production"
    exit 1
fi

# Copy .env.production to required locations
echo "Copying environment files..."
cp "${PROJECT_DIR}/.env.production" "${DOCKER_DIR}/.env"
cp "${PROJECT_DIR}/.env.production" "${BACKEND_DIR}/.env"

# Step 3: Stop existing containers (if restart flag)
if [ "$RESTART" = true ]; then
    echo -e "\n${YELLOW}[3/6] Stopping existing containers...${NC}"
    cd "${DOCKER_DIR}"
    docker-compose -f docker-compose.production.yml down || true
fi

# Step 4: Build containers (if build flag)
if [ "$BUILD" = true ]; then
    echo -e "\n${YELLOW}[4/6] Building containers...${NC}"
    cd "${DOCKER_DIR}"
    docker-compose -f docker-compose.production.yml build --no-cache
fi

# Step 5: Start containers
echo -e "\n${YELLOW}[5/6] Starting containers...${NC}"
cd "${DOCKER_DIR}"
docker-compose -f docker-compose.production.yml up -d

# Wait for database to be ready
echo "Waiting for database to be ready..."
sleep 10

# Step 6: Run migrations (if migrate flag)
if [ "$MIGRATE" = true ]; then
    echo -e "\n${YELLOW}[6/6] Running database migrations...${NC}"
    docker-compose -f docker-compose.production.yml exec -T backend flask db upgrade
fi

# Health check
echo -e "\n${YELLOW}Performing health checks...${NC}"
sleep 5

# Check backend health
if curl -s -f http://localhost:5000/health > /dev/null 2>&1; then
    echo -e "${GREEN}Backend: OK${NC}"
else
    echo -e "${RED}Backend: FAILED${NC}"
fi

# Check frontend health
if curl -s -f http://localhost/ > /dev/null 2>&1; then
    echo -e "${GREEN}Frontend: OK${NC}"
else
    echo -e "${YELLOW}Frontend: Not responding (may still be starting)${NC}"
fi

# Show running containers
echo -e "\n${YELLOW}Running containers:${NC}"
docker-compose -f "${COMPOSE_FILE}" ps

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Next steps:"
echo "  - Check logs: docker-compose -f docker/docker-compose.production.yml logs -f"
echo "  - Backend health: curl http://localhost:5000/health"
echo "  - Frontend: http://localhost/"
echo ""
