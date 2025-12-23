FROM osrf/ros:jazzy-desktop-full

ARG USER=ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV WORKSPACE=/home/${USER}/gazebo_differencial_drive_robot
SHELL ["/bin/bash", "-c"]

# Create workspace as root
RUN mkdir -p ${WORKSPACE}/src

# Add sudo privileges
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    dos2unix

COPY requirements.txt .
RUN dos2unix requirements.txt && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    $(cat requirements.txt) && \
    apt-get clean && rm -rf /var/lib/apt/lists/* requirements.txt

# Install fixuid
RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.6.0/fixuid-0.6.0-linux-amd64.tar.gz \
    | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${USER}\ngroup: ${USER}\n" > /etc/fixuid/config.yml

# Create user if needed
RUN usermod -aG sudo ${USER} || true

# Ensure ROS dependencies initialized
RUN rosdep init || true

# Ensure ownership of workspace
RUN chown -R ${USER}:${USER} /home/${USER}

# Add user to groups for serial access
RUN usermod -a -G dialout,plugdev ${USER}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER ${USER}

# Source workspace automatically
RUN echo ". /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc && \
    echo ". ${WORKSPACE}/install/setup.bash" >> ~/.bashrc

WORKDIR ${WORKSPACE}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]