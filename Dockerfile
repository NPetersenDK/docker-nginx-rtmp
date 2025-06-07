FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpcre3-dev \
    libssl-dev \
    zlib1g-dev \
    wget \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp

# Download and extract the latest stable Nginx
RUN wget http://nginx.org/download/nginx-1.28.0.tar.gz && \
    tar -zxf nginx-1.28.0.tar.gz && \
    rm nginx-1.28.0.tar.gz

# Clone the RTMP module repository
RUN git clone https://github.com/arut/nginx-rtmp-module.git

# Compile Nginx with RTMP module
WORKDIR /tmp/nginx-1.28.0
RUN ./configure \
    --prefix=/usr/local/nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --add-module=/tmp/nginx-rtmp-module \
    && make \
    && make install

# Clean up
RUN apt-get purge -y build-essential wget git \
    && apt-get autoremove -y \
    && rm -rf /tmp/*

# Forward logs to Docker log collector
RUN ln -sf /dev/stdout /usr/local/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/nginx/logs/error.log

# Expose HTTP and RTMP ports
EXPOSE 80 1935

# Start Nginx
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]