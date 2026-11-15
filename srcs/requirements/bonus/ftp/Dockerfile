
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        vsftpd \
        openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty /var/log/vsftpd

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/start-ftp.sh /usr/local/bin/start-ftp.sh

RUN chmod +x /usr/local/bin/start-ftp.sh

EXPOSE 21 21100-21110

CMD ["/usr/local/bin/start-ftp.sh"]
