FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar herramientas adicionales para el host pivot
RUN apt-get update && apt-get install -y \
    openssh-server \
    netcat-openbsd \
    iproute2 \
    net-tools \
    nmap \
    curl \
    wget \
    vim \
    iputils-ping \
    tcpdump \
    socat \
    proxychains4 \
    && rm -rf /var/lib/apt/lists/*

# Habilitar IP forwarding permanentemente para pivoting
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Configurar SSH
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Exponer puerto SSH
EXPOSE 22

# Comando por defecto: iniciar SSH daemon
CMD ["/usr/sbin/sshd", "-D"]