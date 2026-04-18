# cationdns

A lightweight Dynamic DNS client for the IONOS Hosting API, written in POSIX shell.

## Requirements

- `sh`
- `curl`

## Installation

```sh
sudo ./install.sh
```

This installs `cationdns` to `/usr/local/bin` and copies `cationdns.conf.example` to `/etc/cationdns/cationdns.conf` (skipped if a config file already exists).

## Configuration

Edit `/etc/cationdns/cationdns.conf` and fill in your IONOS API credentials. You can create a Hosting API key in your IONOS Developer API Portal.

> **Note:** This uses the IONOS Hosting API, not the IONOS Cloud API.

## Usage

> **First time?** Start with `add` to register your domains and generate the update URL. Once that's done, run `update` to push your current IP. From then on, `update` is the only command you need to run regularly.

### Global options

| Option | Description |
|---|---|
| `-V, --version` | Print version and exit |
| `-C, --dir <dir>` | Config directory (default: `/etc/cationdns`) |
| `-c, --config <file>` | Config file (default: `<dir>/cationdns.conf`) |

These are specified before the verb, e.g. `cationdns -C /custom/dir update -f`

### Add a Dynamic DNS entry

Creates a new Dynamic DNS entry and saves the configuration to `/etc/cationdns/<bulkId>.json`.

```sh
cationdns add (-D|--description) <desc> (-d|--domain) <domain> [(-d|--domain) <domain> ...] [(-p|--protocols) "<protocols>"]
```

The optional `-p` flag controls which IP versions are updated for this entry. Accepted values are `ipv4`, `ipv6`, or `"ipv4 ipv6"` (both). Defaults to both if omitted.

Examples:

```sh
# Both IPv4 and IPv6 (default)
cationdns add -D "MyDynDNS" -d "home.example.com" -d "www.example.com"

# IPv4 only
cationdns add -D "MyDynDNS" -d "home.example.com" -p "ipv4"

# IPv6 only
cationdns add -D "MyDynDNS" -d "home.example.com" -p "ipv6"
```

### Update DNS with current IP

Fetches the current public IP address(es) and updates all entries if any have changed. Only the protocols configured for each entry are checked and sent. Optionally target a single entry by bulk ID. Use `-f` to force an update regardless of cached state.

```sh
cationdns update [-f|--force] [<bulkId>]
```

### List Dynamic DNS entries

Shows all configured entries with their bulk ID, description, protocols, and domains. Use the bulk ID from this output to target `edit` and `delete`.

```sh
cationdns list
```

### Edit a Dynamic DNS entry

Updates the domain list, description, and/or protocols for an existing entry. The local configuration is updated to stay in sync. If `-p` is omitted, the existing protocols setting is preserved.

```sh
cationdns edit <bulkId> (-D|--description) <desc> (-d|--domain) <domain> [(-d|--domain) <domain> ...] [(-p|--protocols) "<protocols>"]
```

### Delete a Dynamic DNS entry

Removes the entry from IONOS and cleans up local configuration. The DNS records themselves are not deleted.

```sh
cationdns delete <bulkId>
```

### Delete all Dynamic DNS entries

Removes all Dynamic DNS configurations (bulk IDs and their update URLs) associated with the API key. The DNS records themselves are not deleted.

```sh
cationdns delete_all
```

## Automating updates

### systemd timer (recommended)

A systemd service and timer are provided and run `cationdns update` every minute (with a randomised delay of up to 10 seconds). The timer waits for the network to be online before firing and persists missed runs across reboots.

**RPM package** — the timer is enabled automatically on install via the included preset (`50-cationdns.preset`). No extra steps are needed.

**Manual install** — `install.sh` will ask whether to install and enable the timer when systemd is detected:

```
Install systemd timer to run cationdns every minute? [y/N]
```

Answer `y` to install `cationdns.service` and `cationdns.timer` to `/etc/systemd/system/` and enable the timer immediately.

To check the timer status at any time:

```sh
systemctl status cationdns.timer
```

### cron (alternative)

If you prefer cron or are running a system without systemd, add a cron job instead:

```sh
* * * * * /usr/local/bin/cationdns update
```

## License

GPL-3.0-or-later
