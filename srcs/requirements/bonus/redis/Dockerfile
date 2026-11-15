FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 6379

#CMD ["sh", "-c", "exec redis-server --protected-mode yes --bind 0.0.0.0 --requirepass \"$REDIS_PASSWORD\""]
CMD ["sh", "-c", "test -n \"$REDIS_PASSWORD\" || { echo 'ERROR: REDIS_PASSWORD is required'; exit 1; }; exec redis-server --protected-mode yes --bind 0.0.0.0 --requirepass \"$REDIS_PASSWORD\""]