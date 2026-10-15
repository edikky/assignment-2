# Assignment 2: Dockerized Diagnostic CLI

A Bash diagnostic tool packaged as a Docker image. It can show system information, check a network host, and display disk usage.

## Project structure

```
assignment-2/
├── README.md
├── app/
│   ├── diagnostic.sh      # the CLI
│   └── health-check.sh    # used by the Docker HEALTHCHECK
├── Dockerfile
├── compose.yaml
├── .dockerignore
├── test.sh                # tests for the Docker image
└── grade.sh               # local grader
```

## Prerequisites

- Linux (or WSL on Windows)
- Docker
- Docker Compose (v2, the `docker compose` command)

## Installation / setup

```bash
git clone <your-repository-url>
cd <repository>
chmod +x grade.sh test.sh app/*.sh
docker build -t diagnostic-tool .
```

## Usage

```bash
docker run --rm diagnostic-tool system          # system information
docker run --rm diagnostic-tool network <host>  # check a host
docker run --rm diagnostic-tool disk            # disk information
docker run --rm diagnostic-tool help            # show usage
```

Examples:

```bash
docker run --rm diagnostic-tool network localhost
docker run --rm diagnostic-tool network example.com
```

### Using Docker Compose

```bash
docker compose run --rm diagnostic system
docker compose run --rm diagnostic disk
docker compose run --rm diagnostic network localhost
```

## Commands

| Command | Description |
|---------|-------------|
| `system` | Hostname, user, date, OS, kernel, architecture, uptime, CPU cores and memory |
| `network <host>` | Validates the host, resolves it and runs a ping check |
| `disk` | Shows disk usage for all filesystems |
| `help` | Shows commands and usage |

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Operational or runtime failure (e.g. host cannot be resolved) |
| 2 | Invalid command or input (e.g. unknown command, missing host) |

## Testing

Run the Docker image tests:

```bash
./test.sh
```

They cover `help`, `system`, `disk`, an invalid command, and `network` with no host.

Run the full local grader:

```bash
./grade.sh
```

## Docker notes

- Base image: `alpine:3.20`, chosen because it is lightweight.
- Only the required packages are installed (`bash`, `procps`, `iputils`).
- `.dockerignore` keeps `.git`, logs and local files out of the build.
- `ENTRYPOINT` runs the CLI, and `CMD` defaults to `help`.
- A `HEALTHCHECK` runs `health-check.sh`.

## Assumptions

- Docker and Docker Compose are installed and the Docker daemon is running.
- The `network` command needs outbound network access from the container. If ICMP (ping) is blocked, it reports the host as unreachable even when DNS resolution works.
- No secrets, tokens or credentials are stored in this repository.