#!/bin/bash
# bootstrap.sh
# Downloads the singbox-manager release tar from GitHub and runs the installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/MihailRobot/vless-manager/main/bootstrap.sh | sudo bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[[ ${EUID} -ne 0 ]] && error "Run as root: sudo bash $0"

ARCHIVE_NAME="singbox-manager.tar.gz"
DOWNLOAD_URL="https://github.com/MihailRobot/vless-manager/raw/refs/heads/main/singbox-manager.tar.gz"

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │        sing-box Manager Bootstrap            │"
echo "  └──────────────────────────────────────────────┘"
echo ""

# ── Dependencies ───────────────────────────────────────────────────────────────
if ! command -v curl >/dev/null 2>&1; then
    info "Installing curl..."
    apt-get update -qq && apt-get install -y -qq curl
fi

# ── Download & extract ─────────────────────────────────────────────────────────
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

EXTRACT_DIR="${TMP_DIR}/singbox-manager"
mkdir -p "${EXTRACT_DIR}"

info "Downloading from: ${DOWNLOAD_URL}"
curl -fSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ARCHIVE_NAME}" || \
    error "Download failed. Make sure singbox-manager.tar.gz is committed to the main branch."

success "Downloaded ${ARCHIVE_NAME}"

info "Extracting archive..."
tar -xzf "${TMP_DIR}/${ARCHIVE_NAME}" -C "${EXTRACT_DIR}"

[[ ! -f "${EXTRACT_DIR}/install.sh" ]] && error "install.sh not found inside archive."

success "Extracted successfully"

# ── Run installer ──────────────────────────────────────────────────────────────
chmod +x "${EXTRACT_DIR}/install.sh"
info "Running install.sh..."
echo ""

cd "${EXTRACT_DIR}"
bash install.sh
