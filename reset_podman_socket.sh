#!/bin/bash
# owner: XCS HornetGit
# created: 14 july 2025
# licence: MIT

# Stop everything but don't reset yet
podman stop --all
podman rm --all
podman system prune -f
podman network prune -f

# Stop socket first
systemctl --user stop podman.socket

# Clean the namespace issue
rm -rf /run/user/1001/containers/networks/rootless-netns/

# Now reset (this removes socket config too)
podman system reset --force

# Recreate socket properly
systemctl --user daemon-reload
systemctl --user enable podman.socket
systemctl --user start podman.socket

# Wait and check
sleep 3
systemctl --user status podman.socket
ls -la /run/user/$(id -u)/podman/podman.sock

# Test socket works
podman --remote ps