# Use official Ruby image as base
FROM ruby:3.2-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    vim \
    less \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Create a non-root user for development
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install bundler
RUN gem install bundler

# Grant ownership of bundle directory to non-root user
RUN chown -R $USERNAME:$USERNAME /usr/local/bundle

# Switch to non-root user
USER $USERNAME

# Set up shell
RUN echo 'PS1="\[\e[32m\]\u@\h\[\e[m\]:\[\e[34m\]\w\[\e[m\]\$ "' >> ~/.bashrc

# Expose default port
EXPOSE 4567

# Default command
CMD ["bash"]
