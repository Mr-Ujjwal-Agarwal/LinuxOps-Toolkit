#!/bin/bash

# ==========================================
# LinuxOps Toolkit Configuration
# ==========================================

# Project Information
APP_NAME="LinuxOps Toolkit"
APP_VERSION="1.0.0"
APP_AUTHOR="Ujjwal Agarwal"

# Directories
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODULE_DIR="$BASE_DIR/modules"
UTILS_DIR="$BASE_DIR/utils"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
ASSET_DIR="$BASE_DIR/assets"

# Default Files
BANNER_FILE="$ASSET_DIR/banner.txt"

# Colors Enabled
ENABLE_COLORS=true

# Default Delay (seconds)
LOADER_DELAY=0.05
