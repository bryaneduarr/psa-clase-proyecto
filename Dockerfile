FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    nano \
    git \
    sudo \
    shellcheck \
    iproute2 \
    zstd \
    sudo && apt clean && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY requirements.txt /workspace/

RUN pip install --no-cache-dir -r requirements.txt

CMD ["bash"]