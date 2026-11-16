# FTP Set up a FTP server container pointing to the volume of your WordPress website.

## Shared WordPress Volume: WordPress and FTP

The WordPress and FTP containers share the same Docker volume: `wordpress_data`.

This allows the FTP server to access the WordPress website files directly, without creating a separate copy of the data.

### Architecture

```text
                 WORDPRESS CONTAINER
                    /var/www/html
                          |
                          |
                    wordpress_data
                    /home/mamaimai/data/wordpress
                    (Docker volume)
                          |
                          |
                     FTP CONTAINER
                    /var/www/html
```

### How it works

- **WordPress container:** Uses the `wordpress_data` volume mounted at `/var/www/html`.
- **FTP container:** Uses the same `wordpress_data` volume, also mounted at `/var/www/html`.
- **Persistent storage:** The volume is connected to the host directory `/home/mamaimai/data/wordpress`.

### Docker Compose configuration

Both services reference the same named volume:

```yaml
volumes:
  - wordpress_data:/var/www/html
```

The volume is defined as a bind mount:

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mamaimai/data/wordpress
```

### Advantages

- Both containers access the same WordPress files.
- Files uploaded through FTP are available to WordPress.
- WordPress data remains persistent if containers are stopped, removed or recreated.
- No duplicate WordPress installation is needed in the FTP container.

`We'll mount wordpress_data into the FTP container at /var/www/html, just as WordPress does.`

we also created FTP certificate ssl . we generate the certificate inside the Docker image, rathe rthan putting a private key in Git repository.

and we'll generate the FTPS certificate automatically when the FTP container starts.

This certificate is self-signed, so your FTP client may ask you to trust it the first time you connect.

A shell is a program that allows a user to interact with Linux by typing commands.

`/usr/sbin/nologin` It's a special program that prevents a user from opening a normal interactive terminal session.

ex:
        Username: ftpuser
        Shell: /usr/sbin/nologin
This means:
        The user cannot normally log in through SSH and execute Linux commands.

        The user can still authenticate through FTP, provided the FTP server's authentication configuration allows it.

3. Why do we add it to /etc/shells?
Your /etc/shells file contains a list of shells considered valid by certain Linux authentication programs.

vsftpd uses PAM (Pluggable Authentication Modules) to authenticate FTP users.

Some PAM configurations check whether the user's shell appears in /etc/shells.

`cat /etc/shells` contains a list of shells considered valid by certain Linux authentication programs.

vsftpd uses PAM (Pluggable Authentication Modules) to authenticate FTP users.

Some PAM configurations check whether the user's shell appears in /etc/shells.

`In simple terms: We want the FTP user to transfer WordPress files, not to have a normal Linux terminal inside the container. That's why we're using /usr/sbin/nologin.` 

## test port 21 inside the vm
        nc -v 127.0.0.1 21
        (we can see 220 (vsFTP 3.0.3))
ftp use different ports for different tasks:
port 21 : Control connection: login, commands, directory navigation
port 21100-21110 :  Passive data connections: listing directories and transferring files

127.0.0.1 means my own vm
21 is the ftp control port
220 (vsFTPd 3.0.3) is the server's greeting, confirming it is ready to communicate.

`rebuild image FTP` `docker compose -f srcs/docker-compose.yml up -d ftp`

`docker compose -f srcs/docker-compose.yml ps ftp`

Test authenticated FTPS: `curl -v --ssl-reqd --insecure --user ftpuser ftp://127.0.0.1/`


## Test FTP upload safely using a temporary file
step1 Create a test file inside the FTP container    
                                `docker exec ftp touch /var/www/html/ftp-test.txt`
        
check it was created:
                                `docker exec ftp ls -l /var/www/html/ftp-test,txt`

Step 2 — Check the FTP user's permissions
                                `docker exec ftp id ftpuser`

                                `docker exec ftp ls -ld /var/www/html /var/www/html/wp-content`


#### for uploadding a file
`step1`: verify ftp_uploads exist in the wordpress container
                                `docker exec wordpress ls -ld /var/www/html/wp-content/ftp-uploads`
it shows:
                                `drwxrwsr-x 2 root www-data 4096 Nov 16 10:29 /var/www/html/wp-content/ftp-uploads`

`root` owns the directory.
`www-data` is its group.
`rwx` means the owner can read, write and enter.
`rws` means the group can also write, and the setgid bit ensures new files inherit the www-data group.
`r-x` means others can read and enter, but cannot write.

test the upload file is visible from Wordpress:
                                docker exec wordpress ls -l /var/www/html/wp-content/ftp-uploads/


--------------------------------------------
## upload a file from project directory to FTP server

### step 1 Make sure the FTP container is running
        `docker compose -f srcs/docker-compose.yml up -d --force-recreate ftp`

also check this container is running
        `docker ps`

### step2: Check that the destination folder exists

        `docker exec ftp ls -ld /var/www/html/wp-content/ftp-uploads`

if it says the directory is not exit, create it

        `sudo exec ftp mkdir -p /var/www/html/wp-content/ftp-uploads`

### step3 Upload file

if we want to upload our README_BONUS.md and it is in our current directory

        `ls -l README_BONUS.md`

after that:

        `curl --ssl-reqd --insecure --user ftpuser \ -T README_BONUS.md \ ftp://127.0.0.1/wp-content/ftp-uploads/`

Enter your FTP password when prompted.
- --ssl-reqd: requires an encrypted TLS connection.
- --insecure: accepts our self-signed certificate for this test.
- --user ftpuser: logs in with your FTP username.
- -T: uploads the file.
- The URL specifies the destination folder.

### step 4 verify the upload

1. check from the FTP container

        `docker exec ftp ls -lh /var/www/html/wp-content/ftp-uploads/`

2. then check from Wordpress

        `docker exec wordpress ls -lh /var/www/html/wp-content/ftp-uploads/`

You should see README_BONUS.md in both places. This confirms that FTP and WordPress share the same volume.

### step 5 check the file content
        `docker exec wordpress head -n 20 /var/www/html/wp-content/ftp-uploads/README_BONUS.md`

### clean up the files
1.

        `docker exec ftp rm -f /var/www/html/ftp-test.txt`

2.

        `docker exec ftp rm -f /var/www/html/wp-content/ftp-uploads/test.txt`

3.

        `docker exec ftp rm -f /var/www/html/wp-content/ftp-uploads/ftp-test.txt`

for verify they are gone:

        `docker exec ftp ls -la /var/www/html/wp-content/ftp-uploads/`

        `docker exec ftp ls -la /var/www/html/`

### download the file from FTP

#### STEP1

        `curl --ssl-reqd --insecure --user ftpuser \
        -o README_BONUS_downloaded.md \
        ftp://127.0.0.1/wp-content/ftp-uploads README_BONUS.md`

#### STEP2 Check download file
        `ls -lh README_BONUS_downloaded.md`

#### STEP3 Compare both files
        `diff README_BONUS.md README_BONUS_downloaded.md`



------------------------------------------------------
`vsftpd`: Very Secure FTP Daemon

It is an FTP server software that you installed inside your FTP Docker container.

1. In your Inception , it has following role:
2. It runs inside your ftp container.
3. It allows an FTP user (ftpuser) to connect to your server.
4. It allows the user to upload and download files.
5. It uses your shared WordPress volume (/var/www/html) to store files.
6. You configured it to use TLS encryption, so your FTP connections use FTPS.

                +-----------------------------+
                |       My Debian VM          |
                |                             |
                |  FTP Client: curl           |
                +-----------------------------+
                        |
                        | FTPS (TLS encryption)
                        v
                +-----------------------------+
                |     FTP Docker Container    |
                |                             |
                |  vsftpd (FTP Server)        |
                +-----------------------------+
                        |
                        | Shared volume
                        v
                +-----------------------------+
                |     WordPress Volume        |
                |                             |
                |       /var/www/html         |
                +-----------------------------+


vsftpd means Very Secure FTP Daemon. It is the FTP server software I use in my FTP Docker container. I configured it with TLS encryption to secure file transfers and connected it to the WordPress volume so that uploaded files are accessible to WordPress.

`useful distinction`

`FTP`: File Transfer Protocol, without encryption by default

`FTPS`: FTP secured with TLS encryption

`SFTP` : SSH File Transfer Protocol, a different protocol

Remember: Your project uses vsftpd with FTPS, not SFTP.