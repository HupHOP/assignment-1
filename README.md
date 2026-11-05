# Assignment 1 - Linux Diagnostic Toolkit

Three Bash scripts that report system information, check disk usage against
a threshold, and run basic network diagnostics. Everything is read from the
system at runtime, so nothing is hardcoded to one machine.

## Setup

```bash
git clone <your-repository-url>
cd assignment-1
chmod +x *.sh
```

Requires Linux with Bash and the standard tools `df`, `awk`, `getent` and `ip`.
`ping` and `timeout` are used when available.

## Usage

### system-info.sh

```bash
./system-info.sh
```

Prints hostname, current user, date/time, OS, kernel version, uptime, CPU
model and cores, memory and the working directory.

### disk-check.sh

```bash
./disk-check.sh <threshold> [path]
```

The threshold is a whole number from 1 to 100. The path defaults to `/`.

| Exit code | Meaning |
|-----------|---------|
| 0 | usage is below the threshold |
| 1 | usage reached or exceeded the threshold, or `df` failed |
| 2 | invalid input |

### network-check.sh

```bash
./network-check.sh <hostname-or-ip> [port]
```

Validates the host, resolves it, pings it, lists network interfaces and, if
a port (1-65535) is given, tests the TCP connection.

| Exit code | Meaning |
|-----------|---------|
| 0 | all checks passed |
| 1 | resolution, ping or TCP check failed |
| 2 | invalid input |

## Logging

Every script appends timestamped lines to `logs/toolkit.log`:

```
2026-11-04 16:27:52 [system-info] Collecting system information
```

The format is `date time [script] message`. Log files are ignored by Git;
only `logs/.gitkeep` is tracked.

## Testing

```bash
./grade.sh
```

Manual spot checks:

```bash
./disk-check.sh 0; echo $?                    # 2
./disk-check.sh 100 /; echo $?                # 0
./network-check.sh localhost abc; echo $?     # 2
./network-check.sh 127.0.0.1 1; echo $?       # 1 (port closed)
```

## Assumptions

- Built and tested on Ubuntu under WSL2. Other Linux distributions should work but were not tested.
- If `ping` is not installed, the ICMP check is skipped with a notice. If it is installed but gets no reply (for example, ICMP is blocked), that counts as a failure and the script exits with code 1.
- Host validation accepts hostnames and IPv4 addresses (letters, digits, dots, hyphens). IPv6 literals are rejected as invalid input.
- TCP checks use Bash's built-in `/dev/tcp` with `timeout`, so `nc` and `telnet` are not required.
- No script needs root privileges or changes anything on the system.

## Git workflow

Work was done on `feature/diagnostic-scripts` and merged into `main` with a
merge commit. The feature branch was kept for history.
