# .devcontainer/Dockerfile
# -------------------------------------------------------------------------------------------------------------
# Base image: pin to a specific PowerShell + distro for reproducibility.
# See tags: https://mcr.microsoft.com/en-us/product/powershell/tags
# Example tag below targets PowerShell 7.4 on Ubuntu 22.04 (Jammy).
# -------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

# Create a non-root user (recommended for devcontainers)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV DEBIAN_FRONTEND=noninteractive \
    POWERSHELL_TELEMETRY_OPTOUT=1 \
    POWERSHELL_UPDATECHECK=Off

# Install common tools and set up the non-root user with passwordless sudo
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
    git openssh-client less iproute2 procps ca-certificates sudo \
    && groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd -s /bin/bash --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# OPTIONAL: Preinstall core build modules to speed up first run (cached in image layer).
# Comment out if you prefer postCreate-only installs.
# - PSDepend pulls the rest per requirements.psd1 during your bootstrap step.
RUN pwsh -NoLogo -NoProfile -Command \
    "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
    Install-Module PSDepend -Scope AllUsers -Force -ErrorAction Stop"

# Use the non-root user by default (matches devcontainer.json 'remoteUser')
USER ${USERNAME}
