"""
Gunicorn Configuration für Production
======================================
Optimiert für DigiDekan Backend
"""

import multiprocessing
import os

# ============================================================================
# Server Socket
# ============================================================================
bind = "0.0.0.0:5000"
backlog = 2048

# ============================================================================
# Worker Processes
# ============================================================================
# Empfohlen: (2 x CPU_CORES) + 1
workers = multiprocessing.cpu_count() * 2 + 1

# Worker Class
# - sync: Standard, blockierend (gut für CPU-intensive Tasks)
# - gevent/eventlet: Async (gut für viele I/O-Operationen)
worker_class = "sync"

# Connections per Worker
worker_connections = 1000

# Worker Lifecycle
max_requests = 1000  # Worker neu starten nach N Requests (Memory Leaks vermeiden)
max_requests_jitter = 50  # Randomize restart um Thundering Herd zu vermeiden
timeout = 30  # Request Timeout in Sekunden
graceful_timeout = 30  # Zeit für graceful shutdown
keepalive = 2  # Keep-Alive Connections

# ============================================================================
# Logging
# ============================================================================
# Log Files
accesslog = os.getenv("ACCESS_LOG", "/var/log/digidekan/access.log")
errorlog = os.getenv("ERROR_LOG", "/var/log/digidekan/error.log")

# Log Level: debug, info, warning, error, critical
loglevel = os.getenv("LOG_LEVEL", "warning").lower()

# Access Log Format
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s" %(D)s'
# Legende:
# %(h)s - Remote IP
# %(l)s - Remote user (meist '-')
# %(u)s - Username
# %(t)s - Timestamp
# %(r)s - Request line
# %(s)s - Status code
# %(b)s - Response length
# %(f)s - Referer
# %(a)s - User-Agent
# %(D)s - Request time in microseconds

# ============================================================================
# Process Naming
# ============================================================================
proc_name = "digidekan"

# ============================================================================
# Server Mechanics
# ============================================================================
daemon = False  # Nicht als Daemon laufen (Docker managed das)
pidfile = None  # PID File (nicht benötigt in Docker)
umask = 0  # File Permission Mask
user = None  # User to run as (None = aktueller User)
group = None  # Group to run as
tmp_upload_dir = None  # Temp Directory für File Uploads

# ============================================================================
# Security
# ============================================================================
# Request Line Limits (gegen DoS)
limit_request_line = 4096  # Max Länge der Request-Line
limit_request_fields = 100  # Max Anzahl Header Fields
limit_request_field_size = 8190  # Max Größe eines Header Fields

# ============================================================================
# SSL (Optional - wenn direkt über Gunicorn statt Nginx)
# ============================================================================
# Uncomment wenn du SSL direkt über Gunicorn machen willst:
# keyfile = "/path/to/keyfile.key"
# certfile = "/path/to/certfile.crt"
# ca_certs = "/path/to/ca_certs.pem"
# cert_reqs = 0  # SSL Certificate Requirements (0=CERT_NONE, 1=CERT_OPTIONAL, 2=CERT_REQUIRED)

# ============================================================================
# Hooks (Optional)
# ============================================================================

def on_starting(server):
    """
    Called just before the master process is initialized.
    """
    server.log.info("Starting Gunicorn server...")


def on_reload(server):
    """
    Called to recycle workers during a reload via SIGHUP.
    """
    server.log.info("Reloading Gunicorn server...")


def when_ready(server):
    """
    Called just after the server is started.
    """
    server.log.info("Gunicorn server is ready. Spawning workers...")


def pre_fork(server, worker):
    """
    Called just before a worker is forked.
    """
    pass


def post_fork(server, worker):
    """
    Called just after a worker has been forked.
    """
    server.log.info(f"Worker spawned (pid: {worker.pid})")


def pre_exec(server):
    """
    Called just before a new master process is forked.
    """
    server.log.info("Forked child, re-executing.")


def worker_int(worker):
    """
    Called just after a worker exited on SIGINT or SIGQUIT.
    """
    worker.log.info(f"Worker received INT or QUIT signal (pid: {worker.pid})")


def worker_abort(worker):
    """
    Called when a worker received the SIGABRT signal.
    """
    worker.log.info(f"Worker received SIGABRT signal (pid: {worker.pid})")


# ============================================================================
# Tuning-Hinweise
# ============================================================================
# 1. Workers:
#    - CPU-bound: (2 x CPU) + 1
#    - I/O-bound: Mehr Workers (4-12 je nach Load)
#
# 2. Worker Class:
#    - sync: Standard, einfach, robust
#    - gevent: Async, gut für viele kleine Requests
#    - eventlet: Ähnlich gevent
#
# 3. Timeout:
#    - Standard: 30s
#    - Lange Requests: 60-120s
#    - Hinter Load Balancer: Timeout < LB Timeout
#
# 4. Max Requests:
#    - Verhindert Memory Leaks
#    - Standard: 1000-5000
#    - Mit Jitter: Vermeidet simultane Restarts
#
# 5. Keep-Alive:
#    - Standard: 2-5s
#    - Hinter Load Balancer: Keep-Alive > LB Keep-Alive
# ============================================================================
