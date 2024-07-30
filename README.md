# PostgreSQL Auto-Tuner

## Description
PostgreSQL Auto-Tuner is a tool that automates the process of optimizing PostgreSQL configuration. It combines the power of pgtune with the ability to retain existing custom settings, creating a balanced solution between optimal performance and system stability.

## Key Features
- Automatically optimizes PostgreSQL parameters based on hardware configuration and workload type.
- Retains custom parameters from the current configuration.
- Creates a backup of the old configuration file before applying changes.
- Automatically restarts PostgreSQL to apply the new configuration.
- Supports native PostgreSQL installation on Ubuntu.

## System Requirements
- Ubuntu (or similar Linux distributions)
- PostgreSQL installed
- Sudo privileges to make configuration changes

## Usage
1. Clone this repository to your machine.
2. Ensure the `pgtune.sh` file is in the same directory as the main script.
3. Run the script with sudo privileges:

sudo ./pgtuned.sh

4. The script will automatically detect the PostgreSQL version, optimize the configuration, and restart the service.

## Optional Parameters
The script supports the following parameters:
- `PG_VERSION`: PostgreSQL version
- `DB_TYPE`: Database type (e.g., web, oltp, dw)
- `TOTAL_MEM`: Total system memory
- `CPU_COUNT`: Number of CPUs
- `MAX_CONN`: Maximum connections
- `STGE_TYPE`: Storage type (e.g., ssd, hdd)

Example:
sudo PG_VERSION=16 DB_TYPE=web TOTAL_MEM=8GB CPU_COUNT=4 ./pgtuned.sh

## Interactive Mode
When run without parameters, the script will interactively prompt for each configuration option. Default values are provided where possible, which can be accepted by pressing Enter.

Example:
sudo ./pgtuned.sh

Follow the prompts to input or confirm each parameter.

# CURL instead of clone

```bash
curl -sSL https://raw.githubusercontent.com/vuhoanglam/pgtune/main/pgtuned.sh -o /tmp/pgtuned.sh
curl -sSL https://raw.githubusercontent.com/vuhoanglam/pgtune/main/pgtune.sh -o /tmp/pgtune.sh

chmod +x /tmp/pgtuned.sh /tmp/pgtune.sh

cd /tmp

sudo /tmp/pgtuned.sh
```

## Warning
- Always backup your data and configuration before making significant changes.
- Carefully check PostgreSQL logs after applying the new configuration.
- In production environments, plan for maintenance before applying changes.

## Contributing
Contributions are welcome. Please create an issue or pull request if you have any improvements.

## License

