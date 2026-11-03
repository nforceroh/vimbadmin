# vimbadmin

[ViMbAdmin](https://github.com/opensolutions/ViMbAdmin) — web-based mailbox and
domain management for Postfix/Dovecot virtual mail setups — on
[nginx-php](https://github.com/nforceroh/nginx-php) (nginx + PHP 8.5 + composer)
with s6-overlay.

Pinned to ViMbAdmin release `3.4.1` (the `VIMBADMIN_VERSION` ARG); bump the ARG to
upgrade. PHP 8.5 verified: composer install clean, app boots, login page renders
with no PHP fatals or deprecations.

## Configuration

Runtime environment variables (substituted into `application.ini` at container
start by `init-vimbadmin`):

| Variable | Default | Description |
| --- | --- | --- |
| `VIMBADMIN_DB_NAME` | `vimbadmin` | database name |
| `VIMBADMIN_DB_USER` | `vimbadmin2` | database user |
| `VIMBADMIN_DB_PASSWORD` | `vimbadmin2` | database password — set a real value via your deployment's secret |
| `VIMBADMIN_DB_HOST` | `db` | database host |
| `ADMIN_EMAIL` | `postmaster@example.com` | address used for the admin setup flow |
| `ADMIN_PASSWORD` | `CHANGEME` | initial admin password — set a real value via your deployment's secret |
| `SMTP_HOST` | `mail` | mail transport host |
| `OPCACHE_MEM_SIZE` | `64` | opcache memory, MB |

`ADMIN_PASSWORD` and `VIMBADMIN_DB_PASSWORD` are credential-shaped: the Dockerfile
defaults are placeholders, and real values arrive at runtime (Kubernetes Secret,
`--env-file`, etc.).

## Runtime layout

| Path | Purpose |
| --- | --- |
| `/data/web/vimbadmin` | the application, owned by `www-data` |
| `/config` | volume inherited from nginx-php; PHP drop-ins at `/config/php/*.conf` |

nginx serves `/data/web/vimbadmin/public` on port 8080 and hands PHP to php-fpm on
127.0.0.1:9000.

## Local development

```sh
make build   # build the image
make test    # build, then run tests/run_tests.sh
make run     # run with 8080 published
```

CI is the only publisher — see
[nforceroh/.github](https://github.com/nforceroh/.github) for the shared build and
cleanup workflows.
