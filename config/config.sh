#!/bin/bash

# ==========================================
# LinuxOps Toolkit Configuration
# ==========================================

APP_NAME="LinuxOps Toolkit"
APP_VERSION="1.0.0"
APP_AUTHOR="Ujjwal Agarwal"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODULE_DIR="$BASE_DIR/modules"
UTILS_DIR="$BASE_DIR/utils"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
ASSET_DIR="$BASE_DIR/assets"

BANNER_FILE="$ASSET_DIR/banner.txt"

ENABLE_COLORS=true
LOADER_DELAY=0.05
