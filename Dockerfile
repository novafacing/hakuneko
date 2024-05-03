# Docker image version is provided via build arg.
ARG DOCKER_IMAGE_VERSION=

# Define software download URLs.
ARG HAKUNEKO_URL=https://github.com/manga-download/hakuneko/releases/download/v6.1.7/hakuneko-desktop_6.1.7_linux_amd64.deb

# Download JDownloader2
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS hn
ARG HAKUNEKO_URL
RUN \
    add-pkg --no-cache add curl ca-certificates && \
    mkdir -p /defaults && \
    curl -# -L -o /defaults/hakuneko-desktop.deb ${HAKUNEKO_URL}

# Pull base image.
FROM jlesage/baseimage-gui:ubuntu:22.04

ARG DOCKER_IMAGE_VERSION

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN \
    add-pkg \
        # Needed by the init script.
        jq \
        # We need a font.
        fonts-dejavu \
        # For ffmpeg and ffprobe tools.
        ffmpeg \
        # For rtmpdump tool.
        rtmpdump \
        # Need for the sponge tool.
        moreutils \
        # For Hakuneko
        libnss3 \
        libgtk-3-0 \
        libxtst6

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/jdownloader-2-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /
COPY --from=hn /defaults/hakuneko-desktop.deb /defaults/hakunkeo-desktop.deb

RUN \
    dpkg -yi /defaults-hakuneko-desktop.deb

# Set internal environment variables.
RUN \
    set-cont-env APP_NAME "Hakuneko" && \
    set-cont-env DOCKER_IMAGE_VERSION "$DOCKER_IMAGE_VERSION" && \
    true

# Define mountable directories.
VOLUME ["/output"]

# Expose ports.
#   - 3129: For MyJDownloader in Direct Connection mode.
EXPOSE 3129

# Metadata.
LABEL \
      org.label-schema.name="hakuneko" \
      org.label-schema.description="Docker container for Hakuneko" \
      org.label-schema.version="${DOCKER_IMAGE_VERSION:-unknown}" \
      org.label-schema.vcs-url="https://github.com/novafacing/hakuneko-docker" \
      org.label-schema.schema-version="1.0"
