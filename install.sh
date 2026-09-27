#!/usr/bin/env bash
# Clone the Vortex repos into the ROS 2 workspace (~/code/ros2_ws/src).
#
# Usage:
#   ./install.sh                 clone over HTTPS into ~/code/ros2_ws/src
#   ./install.sh --ssh           clone over SSH (port 443) instead of HTTPS
#   ./install.sh --ws=PATH       use PATH as the ROS 2 workspace
set -euo pipefail

WS_DIR="$HOME/code/ros2_ws"
USE_SSH=0

# owner/repo|branch
VORTEX_REPOS=(
    "vortexntnu/vortex-auv|rework/isam2"
    "vortexntnu/vortex-msgs|rework/landmark-navigation"
    "vortexntnu/vortex-utils|rework/landmark-navigation"
    "vortexntnu/vortex-vkf|main"
    "vortexntnu/vortex-ci|main"
    "vortexntnu/vortex-cv|rework/isam2"
    "vortexntnu/vortex-aruco-detection|main"
    "vortexntnu/vortex-gstreamer|test/pipeline-drain"
    "vortexntnu/vortex-pyqt-gui|operator-interface"
    "vortexntnu/vortex-stonefish-interface|main"
    "vortexntnu/vortex-stonefish-sim|rework/landmark-navigation"
    "vortexntnu/stonefish_ros2|main"
    "vortexntnu/stim300-driver|feature/ros2-port"
    "uleroboticsgroup/yasmin|main"
)

for arg in "$@"; do
    case "$arg" in
        --ssh) USE_SSH=1 ;;
        --ws=*) WS_DIR="${arg#*=}" ;;
        -h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 1 ;;
    esac
done

command -v git >/dev/null || { echo "git is not installed (sudo apt install git)" >&2; exit 1; }

repo_url() {
    if (( USE_SSH )); then
        # Port 443 works on networks that block port 22.
        echo "ssh://git@ssh.github.com:443/$1.git"
    else
        echo "https://github.com/$1.git"
    fi
}

failed=()

clone_all() {
    local dest_root="$1"; shift
    mkdir -p "$dest_root"
    local entry repo branch dest
    for entry in "$@"; do
        repo="${entry%%|*}"
        branch="${entry#*|}"
        dest="$dest_root/${repo##*/}"
        if [[ -d "$dest/.git" ]]; then
            echo "skip   $repo (already in $dest)"
            continue
        fi
        echo "clone  $repo${branch:+ @ $branch} -> $dest"
        if ! git clone --quiet --branch "$branch" "$(repo_url "$repo")" "$dest"; then
            failed+=("$repo")
        fi
    done
}

clone_all "$WS_DIR/src" "${VORTEX_REPOS[@]}"

if (( ${#failed[@]} )); then
    echo "Failed: ${failed[*]}" >&2
    exit 1
fi
echo "Done."
