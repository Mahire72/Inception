# Use the penultimate stable Debian release
FROM debian:bookworm

# Install NGINX and OpenSSL for HTTPS
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        nginx \
        openssl \
    && rm -rf /var/lib/apt/lists/*

# Create the directory for the TLS certificate and private key
RUN mkdir -p /etc/nginx/ssl

# Generate a self-signed TLS certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=mamaimai.42.fr"

# Copy your NGINX configuration into the image
COPY conf/nginx.conf /etc/nginx/nginx.conf

# HTTPS port used by NGINX
EXPOSE 443

# Keep NGINX in the foreground so Docker can manage it
CMD ["nginx", "-g", "daemon off;"]
