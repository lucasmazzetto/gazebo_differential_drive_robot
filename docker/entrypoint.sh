#!/bin/bash
set -e

# Run fixuid (handles user mapping between host and container)
if command -v fixuid >/dev/null 2>&1; then
    eval "$(fixuid -q)"
fi

# Source ROS 2 environment
if [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
    source "/opt/ros/${ROS_DISTRO}/setup.bash"
else
    echo "Warning: /opt/ros/${ROS_DISTRO}/setup.bash not found."
fi

if [ -n "${WORKSPACE}" ]; then
    cd "${WORKSPACE}"

    # Detect if workspace is already built
    if [ ! -d "build" ] || [ ! -d "install" ]; then
        echo "No workspace build detected. Running rosdep + colcon build..."
        rosdep update
        rosdep install --from-paths . --ignore-src -r -y --rosdistro ${ROS_DISTRO}
        colcon build --symlink-install
    else
        echo "Workspace already built. Skipping colcon build."
    fi

    # Source workspace setup if it exists
    if [ -f "${WORKSPACE}/install/setup.bash" ]; then
        source "${WORKSPACE}/install/setup.bash"
    else
        echo "Warning: install/setup.bash not found even after build."
    fi
else
    echo "Warning: WORKSPACE variable not set."
fi

# Execute final command
exec "$@"
