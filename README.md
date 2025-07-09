# Nginx + Gunicorn + Django Docker Setup

This is a production-ready setup for running Django applications with Nginx and Gunicorn in Docker.

## Features

- **Nginx**: High-performance web server for serving static files and proxying requests to Gunicorn.
- **Gunicorn**: WSGI HTTP Server for UNIX.
- **Django**: High-level Python Web framework.
- **Supervisor**: A client/server system that allows its users to monitor and control a number of processes on UNIX-like operating systems.
- **Unix Socket**: Gunicorn communicates with Nginx through a Unix socket, which is more efficient than a TCP socket.
- **SSL Support**: Easily add your own SSL certificates to enable HTTPS.
- **Alpine Linux**: Both the Nginx and Django images are based on Alpine Linux for a smaller footprint and better security.
- **Templated Nginx Configuration**: The Nginx configuration is templated, allowing you to customize it using environment variables.
- **Cloudflare Support**: Optionally, you can configure Nginx to only accept traffic from Cloudflare's IP addresses.
- **Flexible and Configurable**: The image is highly configurable through environment variables, allowing you to use it for different Django projects with different needs.
- **Optional Certbot Support**: You can optionally enable Certbot to automatically renew your SSL certificates. If you don't need Certbot, you can comment out its service in `docker-compose.yml`.

## How to Use

This repository provides a flexible Docker setup for deploying Django applications with Nginx and Gunicorn. The included `django_app` is a minimal example for testing purposes.

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name
```

### 2. Prepare Your Django Project

Place your Django project in a directory (e.g., `my_django_project`). Ensure it has a `requirements.txt` file and a WSGI application entry point (e.g., `my_django_project/wsgi.py`).

### 3. Configure `docker-compose.yml`

Open `docker-compose.yml` and adjust the environment variables under the `nginx` and `django` services to match your project's needs. Below are the key configuration options:

#### Nginx Service Environment Variables

-   `NGINX_SERVER_NAME`: (Required) Your domain name (e.g., `example.com`). This is used for Nginx server blocks and Certbot.
-   `SSL_CERT_NAME`: (Optional) The filename of your SSL certificate within the `certs` directory (e.g., `cert.pem`). Defaults to `cert.pem`.
-   `SSL_KEY_NAME`: (Optional) The filename of your SSL key within the `certs` directory (e.g., `key.pem`). Defaults to `key.pem`.
-   `CLOUDFLARE_ONLY`: (Optional) Set to `true` to configure Nginx to only accept traffic from Cloudflare's IP ranges. Defaults to `false`.
-   `NGINX_WORKER_PROCESSES`: (Optional) Number of Nginx worker processes. Defaults to `1` (suitable for low-spec VPS).
-   `NGINX_WORKER_CONNECTIONS`: (Optional) Number of Nginx worker connections. Defaults to `256` (suitable for low-spec VPS).
-   `CERTBOT_ENABLED`: (Optional) Set to `true` to enable Certbot for automatic SSL certificate renewal. Requires `NGINX_SERVER_NAME` and `CERTBOT_EMAIL` to be set. Defaults to `false`.
-   `CERTBOT_EMAIL`: (Required if `CERTBOT_ENABLED` is `true`) Your email address for Certbot notifications.

#### Django Service Environment Variables

-   `DJANGO_APP_DIR`: (Optional) The path to your Django application's root directory relative to the `docker-compose.yml` file. Defaults to `django_app`.
-   `DJANGO_APP_NAME`: (Optional) The name of your Django application's WSGI module (e.g., if your WSGI file is `myproject/wsgi.py`, this would be `myproject`). Defaults to `django_app`.
-   `GUNICORN_CMD`: (Optional) The full command used to run Gunicorn. This allows for fine-grained control over Gunicorn settings. Defaults to `gunicorn --workers 2 --bind unix:/run/gunicorn.sock ${DJANGO_APP_NAME:-django_app}.wsgi:application`.

### 4. Provide SSL Certificates (if not using Certbot)

If `CERTBOT_ENABLED` is `false`, you need to manually provide your SSL certificate and key:

-   Place your `cert.pem` (or specified `SSL_CERT_NAME`) and `key.pem` (or specified `SSL_KEY_NAME`) files in the `certs/` directory.

    For development, you can generate a self-signed certificate:

    ```bash
    openssl req -x509 -newkey rsa:4096 -keyout certs/key.pem -out certs/cert.pem -days 365 -nodes
    ```

    When prompted, you can enter any information you like. For the `Common Name`, use your `NGINX_SERVER_NAME` (e.g., `localhost`).

### 5. Build and Run the Containers

```bash
docker-compose up --build
```

### 6. Access Your Application

Once the containers are running, you can access your Django application at `https://<your_NGINX_SERVER_NAME>`.

## Project Structure

```
.
├── certs
│   ├── cert.pem
│   └── key.pem
├── certbot
│   └── www
├── django_app
│   ├── Dockerfile
│   ├── manage.py
│   ├── requirements.txt
│   └── django_app
│       ├── __init__.py
│       ├── asgi.py
│       ├── settings.py
│       ├── urls.py
│       └── wsgi.py
├── Dockerfile
├── docker-compose.yml
├── entrypoint.sh
├── nginx.conf.template
├── README.md
├── supervisord.conf
└── update_cloudflare_ips.sh
```