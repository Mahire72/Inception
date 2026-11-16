Service: vsftpd running in its own Docker container.

Security: FTPS with TLS encryption and a self-signed certificate.

Authentication: credentials stored in .env.

Shared storage: uses the same wordpress_data volume as WordPress.

Upload directory: wp-content/ftp-uploads/.

Permissions: FTP user belongs to the www-data group.

Testing: successful login, directory listing and file upload verified.