#!/bin/bash

###############################################################################
# Digitales Dekanat - Production Deployment Script
###############################################################################
#
# Usage:
#   ./deploy.sh [command]
#
# Commands:
#   setup       - Initial setup (first time deployment)
#   update      - Update existing deployment
#   rollback    - Rollback to previous version
#   backup      - Create database backup
#   check       - Run health checks
#   logs        - Show application logs
#
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="dekanat"
APP_DIR="/opt/dekanat/backend"
VENV_DIR="$APP_DIR/venv"
BACKUP_DIR="/backup/dekanat"
LOG_DIR="/var/log/dekanat"

# Functions

print_header() {
    echo -e "${BLUE}"
    echo "================================================================================"
    echo "  $1"
    echo "================================================================================"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Please run as root (use sudo)"
        exit 1
    fi
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check Python
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        print_success "Python installed: $PYTHON_VERSION"
    else
        print_error "Python 3 not installed"
        exit 1
    fi

    # Check PostgreSQL
    if command -v psql &> /dev/null; then
        print_success "PostgreSQL installed"
    else
        print_error "PostgreSQL not installed"
        exit 1
    fi

    # Check Nginx
    if command -v nginx &> /dev/null; then
        print_success "Nginx installed"
    else
        print_error "Nginx not installed"
        exit 1
    fi

    # Check Git
    if command -v git &> /dev/null; then
        print_success "Git installed"
    else
        print_error "Git not installed"
        exit 1
    fi
}

create_backup() {
    print_header "Creating Database Backup"

    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/${APP_NAME}_$TIMESTAMP.sql"

    mkdir -p "$BACKUP_DIR"

    # Get database credentials from environment
    source "$APP_DIR/.env.production" 2>/dev/null || true

    if [ -z "$DATABASE_URL" ]; then
        print_error "DATABASE_URL not set in .env.production"
        exit 1
    fi

    # Extract database name from URL
    DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    print_info "Backing up database: $DB_NAME"
    sudo -u postgres pg_dump "$DB_NAME" > "$BACKUP_FILE"

    if [ -f "$BACKUP_FILE" ]; then
        BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        print_success "Backup created: $BACKUP_FILE ($BACKUP_SIZE)"
    else
        print_error "Backup failed"
        exit 1
    fi

    # Keep only last 30 backups
    print_info "Cleaning old backups (keeping last 30)"
    ls -t "$BACKUP_DIR"/*.sql | tail -n +31 | xargs -r rm
    print_success "Old backups cleaned"
}

setup_initial() {
    check_root
    check_prerequisites

    print_header "Initial Setup"

    # Create application directory
    print_info "Creating application directory: $APP_DIR"
    mkdir -p "$APP_DIR"
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$LOG_DIR"

    # Clone repository
    if [ ! -d "$APP_DIR/.git" ]; then
        print_info "Cloning repository..."
        read -p "Enter repository URL: " REPO_URL
        git clone "$REPO_URL" "$APP_DIR"
        print_success "Repository cloned"
    else
        print_warning "Repository already exists"
    fi

    cd "$APP_DIR"

    # Create virtual environment
    if [ ! -d "$VENV_DIR" ]; then
        print_info "Creating virtual environment..."
        python3 -m venv "$VENV_DIR"
        print_success "Virtual environment created"
    else
        print_warning "Virtual environment already exists"
    fi

    # Activate virtual environment
    source "$VENV_DIR/bin/activate"

    # Install dependencies
    print_info "Installing dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    print_success "Dependencies installed"

    # Create .env.production if not exists
    if [ ! -f "$APP_DIR/.env.production" ]; then
        print_info "Creating .env.production..."
        cat > "$APP_DIR/.env.production" << EOF
# Flask
FLASK_ENV=production
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
JWT_SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# Database
DATABASE_URL=postgresql://dekanat_user:CHANGE_PASSWORD@localhost:5432/dekanat_prod

# CORS
CORS_ORIGINS=https://yourdomain.com

# Redis (optional)
# RATELIMIT_STORAGE_URL=redis://localhost:6379/0
EOF
        print_success ".env.production created"
        print_warning "IMPORTANT: Edit $APP_DIR/.env.production and set your values!"
        print_warning "Especially DATABASE_URL and CORS_ORIGINS!"
    else
        print_warning ".env.production already exists"
    fi

    # Database setup
    print_info "Setting up database..."
    source "$APP_DIR/.env.production"

    print_info "Please create PostgreSQL database manually:"
    echo ""
    echo "  sudo -u postgres psql"
    echo "  CREATE DATABASE dekanat_prod;"
    echo "  CREATE USER dekanat_user WITH PASSWORD 'your_password';"
    echo "  GRANT ALL PRIVILEGES ON DATABASE dekanat_prod TO dekanat_user;"
    echo "  \\q"
    echo ""
    read -p "Press Enter after database is created..."

    # Run migrations
    print_info "Running database migrations..."
    flask db upgrade
    print_success "Migrations completed"

    # Create systemd service
    print_info "Creating systemd service..."
    cat > /etc/systemd/system/${APP_NAME}.service << EOF
[Unit]
Description=Digitales Dekanat Backend
After=network.target postgresql.service

[Service]
Type=notify
User=www-data
Group=www-data
WorkingDirectory=$APP_DIR
Environment="PATH=$VENV_DIR/bin"
EnvironmentFile=$APP_DIR/.env.production

ExecStart=$VENV_DIR/bin/gunicorn \\
    --config gunicorn_config.py \\
    --workers 4 \\
    --bind 127.0.0.1:8000 \\
    "app:create_app('production')"

ExecReload=/bin/kill -s HUP \$MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$APP_NAME"
    print_success "Systemd service created"

    # Set permissions
    print_info "Setting permissions..."
    chown -R www-data:www-data "$APP_DIR"
    chown -R www-data:www-data "$LOG_DIR"
    print_success "Permissions set"

    # Start service
    print_info "Starting service..."
    systemctl start "$APP_NAME"
    sleep 2
    systemctl status "$APP_NAME" --no-pager
    print_success "Service started"

    print_header "Setup Complete!"
    print_info "Next steps:"
    echo "  1. Edit $APP_DIR/.env.production"
    echo "  2. Configure Nginx (see PRODUCTION_DEPLOYMENT_CHECKLIST.md)"
    echo "  3. Setup SSL with certbot"
    echo "  4. Run health checks: ./deploy.sh check"
}

update_deployment() {
    check_root

    print_header "Updating Deployment"

    cd "$APP_DIR"

    # Create backup first
    create_backup

    # Stop service
    print_info "Stopping service..."
    systemctl stop "$APP_NAME"
    print_success "Service stopped"

    # Pull latest code
    print_info "Pulling latest code..."
    git pull origin main
    print_success "Code updated"

    # Activate virtual environment
    source "$VENV_DIR/bin/activate"

    # Update dependencies
    print_info "Updating dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    print_success "Dependencies updated"

    # Run migrations
    print_info "Running migrations..."
    source "$APP_DIR/.env.production"
    flask db upgrade
    print_success "Migrations completed"

    # Restart service
    print_info "Starting service..."
    systemctl start "$APP_NAME"
    sleep 2
    print_success "Service started"

    # Health check
    print_info "Running health check..."
    sleep 3
    run_health_checks

    print_header "Update Complete!"
}

rollback_deployment() {
    check_root

    print_header "Rolling Back Deployment"

    cd "$APP_DIR"

    # Show recent commits
    print_info "Recent commits:"
    git log --oneline -10

    # Ask for commit to rollback to
    read -p "Enter commit hash to rollback to: " COMMIT_HASH

    if [ -z "$COMMIT_HASH" ]; then
        print_error "No commit hash provided"
        exit 1
    fi

    # Stop service
    print_info "Stopping service..."
    systemctl stop "$APP_NAME"
    print_success "Service stopped"

    # Rollback code
    print_info "Rolling back code to $COMMIT_HASH..."
    git checkout "$COMMIT_HASH"
    print_success "Code rolled back"

    # Activate virtual environment
    source "$VENV_DIR/bin/activate"

    # Reinstall dependencies
    print_info "Reinstalling dependencies..."
    pip install -r requirements.txt
    print_success "Dependencies installed"

    # Database rollback
    print_warning "Database rollback not automated!"
    echo "Latest backups:"
    ls -lht "$BACKUP_DIR"/*.sql | head -5

    read -p "Restore database from backup? (y/N): " RESTORE_DB

    if [ "$RESTORE_DB" = "y" ] || [ "$RESTORE_DB" = "Y" ]; then
        read -p "Enter backup filename: " BACKUP_FILE
        if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
            source "$APP_DIR/.env.production"
            DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')

            print_info "Restoring database: $DB_NAME"
            sudo -u postgres psql "$DB_NAME" < "$BACKUP_DIR/$BACKUP_FILE"
            print_success "Database restored"
        else
            print_error "Backup file not found"
        fi
    fi

    # Restart service
    print_info "Starting service..."
    systemctl start "$APP_NAME"
    sleep 2
    print_success "Service started"

    print_header "Rollback Complete!"
}

run_health_checks() {
    print_header "Running Health Checks"

    # Check service status
    if systemctl is-active --quiet "$APP_NAME"; then
        print_success "Service is running"
    else
        print_error "Service is not running"
        systemctl status "$APP_NAME" --no-pager
        return 1
    fi

    # Check if port is listening
    if netstat -tln | grep -q ":8000"; then
        print_success "Application is listening on port 8000"
    else
        print_error "Application is not listening on port 8000"
        return 1
    fi

    # HTTP Health check (if nginx is configured)
    if command -v curl &> /dev/null; then
        RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
        if [ "$RESPONSE" = "200" ]; then
            print_success "HTTP health check passed (200 OK)"
        else
            print_error "HTTP health check failed (HTTP $RESPONSE)"
            return 1
        fi
    fi

    # Database connection
    source "$APP_DIR/.env.production"
    DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')

    if sudo -u postgres psql -d "$DB_NAME" -c "SELECT 1" &> /dev/null; then
        print_success "Database connection OK"
    else
        print_error "Database connection failed"
        return 1
    fi

    print_header "All Health Checks Passed!"
}

show_logs() {
    print_header "Application Logs"

    echo ""
    echo "Select log to view:"
    echo "  1) Application logs (journalctl)"
    echo "  2) Gunicorn access log"
    echo "  3) Gunicorn error log"
    echo "  4) Nginx access log"
    echo "  5) Nginx error log"
    echo ""

    read -p "Choice [1-5]: " LOG_CHOICE

    case $LOG_CHOICE in
        1)
            journalctl -u "$APP_NAME" -f
            ;;
        2)
            tail -f "$LOG_DIR/gunicorn_access.log"
            ;;
        3)
            tail -f "$LOG_DIR/gunicorn_error.log"
            ;;
        4)
            tail -f /var/log/nginx/dekanat_access.log
            ;;
        5)
            tail -f /var/log/nginx/dekanat_error.log
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
}

# Main

case "${1:-}" in
    setup)
        setup_initial
        ;;
    update)
        update_deployment
        ;;
    rollback)
        rollback_deployment
        ;;
    backup)
        create_backup
        ;;
    check)
        run_health_checks
        ;;
    logs)
        show_logs
        ;;
    *)
        echo "Usage: $0 {setup|update|rollback|backup|check|logs}"
        echo ""
        echo "Commands:"
        echo "  setup       - Initial setup (first time deployment)"
        echo "  update      - Update existing deployment"
        echo "  rollback    - Rollback to previous version"
        echo "  backup      - Create database backup"
        echo "  check       - Run health checks"
        echo "  logs        - Show application logs"
        exit 1
        ;;
esac
