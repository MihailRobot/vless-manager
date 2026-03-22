#!/bin/bash
# bootstrap.sh
# Downloads the singbox-manager release tar from GitHub and runs the installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/vless-manager/main/bootstrap.sh | sudo bash
#
# Or with a specific version:
#   RELEASE_VERSION=1.0.0 bash bootstrap.sh

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


ARCHIVE_NAME="singbox-manager.tar.gz"   # the filename you uploaded to the release
# ──────────────────────────────────────────────────────────────────────────────

echo ""
echo "  ┌──────────────────────────────────────────────┐"
echo "  │        sing-box Manager Bootstrap            │"
echo "  └──────────────────────────────────────────────┘"
echo ""


DOWNLOAD_URL="https://github.com/MihailRobot/vless-manager/raw/refs/heads/main/singbox-manager.tar.gz"


info "Downloading from: ${DOWNLOAD_URL}"

# ── Dependencies ───────────────────────────────────────────────────────────────
if ! command -v curl >/dev/null 2>&1; then
    info "Installing curl..."
    apt-get update -qq && apt-get install -y -qq curl
fi

# ── Download & extract ─────────────────────────────────────────────────────────
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

ARCHIVE_PATH="${TMP_DIR}/${ARCHIVE_NAME}"

curl -fSL "${DOWNLOAD_URL}" -o "${ARCHIVE_PATH}" || \
    error "Download failed. Check your GITHUB_USER/GITHUB_REPO and that the release exists."

success "Downloaded ${ARCHIVE_NAME}"

info "Extracting archive..."
tar -xzf "${ARCHIVE_PATH}" -C "${TMP_DIR}"

# Find the extracted directory (handles any top-level folder name inside the tar)
EXTRACTED_DIR="$(find "${TMP_DIR}" -maxdepth 1 -mindepth 1 -type d | head -n 1)"

[[ -z "${EXTRACTED_DIR}" ]] && error "Could not find extracted directory inside archive."
[[ ! -f "${EXTRACTED_DIR}/install.sh" ]] && error "install.sh not found inside archive. Check your tar structure."

success "Extracted to ${EXTRACTED_DIR}"

# ── Run installer ──────────────────────────────────────────────────────────────
chmod +x "${EXTRACTED_DIR}/install.sh"
info "Running install.sh..."
echo ""

cd "${EXTRACTED_DIR}"
bash install.sh
