#!/bin/sh
#
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026,  Manuel Fombuena <mfombuena@innovara.tech>
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INSTALL_BIN="/usr/local/bin/cationdns"
INSTALL_DIR="/etc/cationdns"
CONF_FILE="${INSTALL_DIR}/cationdns.conf"
COMPLETION_DIR="/usr/share/bash-completion/completions"
COMPLETION_FILE="${COMPLETION_DIR}/cationdns"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: install.sh must be run as root"
    exit 1
fi

cp "$SCRIPT_DIR/cationdns" "$INSTALL_BIN"
chmod 755 "$INSTALL_BIN"
echo "Installed $INSTALL_BIN"

mkdir -p "$INSTALL_DIR"
chmod 700 "$INSTALL_DIR"

if [ -f "$CONF_FILE" ]; then
    echo "Skipping config: $CONF_FILE already exists"
else
    cp "$SCRIPT_DIR/cationdns.conf.example" "$CONF_FILE"
    chown root:root "$CONF_FILE"
    chmod 600 "$CONF_FILE"
    echo "Installed $CONF_FILE"
    echo "Edit $CONF_FILE and fill in your PREFIX and SECRET before use"
fi

if command -v systemctl > /dev/null 2>&1; then
    printf 'Install systemd timer to run cationdns every minute? [y/N]'
    read -r answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
        sed "s|/usr/bin/cationdns|$INSTALL_BIN|" "$SCRIPT_DIR/systemd/cationdns.service" > /etc/systemd/system/cationdns.service
        cp "$SCRIPT_DIR/systemd/cationdns.timer" /etc/systemd/system/cationdns.timer
        systemctl daemon-reload
        systemctl enable --now cationdns.timer
        echo "Installed and started cationdns.timer"
    fi
fi

if [ -d "$COMPLETION_DIR" ]; then
    cp "$SCRIPT_DIR/completion/cationdns.bash-completion" "$COMPLETION_FILE"
    chmod 644 "$COMPLETION_FILE"
    echo "Installed $COMPLETION_FILE"
fi

if command -v restorecon > /dev/null 2>&1; then
    restorecon -Fv "$INSTALL_BIN"
    restorecon -FRv "$INSTALL_DIR"
    [ -f "$COMPLETION_FILE" ] && restorecon -Fv "$COMPLETION_FILE"
    [ -f /etc/systemd/system/cationdns.service ] && restorecon -Fv /etc/systemd/system/cationdns.service
    [ -f /etc/systemd/system/cationdns.timer ] && restorecon -Fv /etc/systemd/system/cationdns.timer
fi
