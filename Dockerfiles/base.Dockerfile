FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Instalar herramientas esenciales para el laboratorio
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
    && rm -rf /var/lib/apt/lists/*

# Configurar SSH
RUN mkdir /var/run/sshd && \
    mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh

# Crear directorio para flags y datos del laboratorio
RUN mkdir -p /opt/lab

# Exponer puerto SSH
EXPOSE 22

# Comando por defecto: iniciar SSH daemon
CMD ["/usr/sbin/sshd", "-D"]