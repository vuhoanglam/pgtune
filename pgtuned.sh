#!/bin/bash
set -e

declare -A tuned
declare -A outoftune

cmd_opts=""

# Function to prompt for input with a default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    read -p "$prompt [$default]: " value
    echo ${value:-$default}
}

# Prompt for each parameter
PG_VERSION=$(prompt_with_default "Enter PostgreSQL version" "$(psql -V | sed 's/^psql (PostgreSQL) //' | cut -d. -f1)")
cmd_opts+=" -v $PG_VERSION"

DB_TYPE=$(prompt_with_default "Enter database type (web, oltp, dw, desktop, mixed)" "web")
cmd_opts+=" -t $DB_TYPE"

TOTAL_MEM=$(prompt_with_default "Enter total system memory (e.g., 4GB, 8GB)" "$(free -h | awk '/^Mem:/{print $2}')")
cmd_opts+=" -m $TOTAL_MEM"

CPU_COUNT=$(prompt_with_default "Enter number of CPUs" "$(nproc)")
cmd_opts+=" -u $CPU_COUNT"

MAX_CONN=$(prompt_with_default "Enter maximum connections" "100")
cmd_opts+=" -c $MAX_CONN"

STGE_TYPE=$(prompt_with_default "Enter storage type (ssd, hdd)" "ssd")
cmd_opts+=" -s $STGE_TYPE"

# Define the path to postgresql.conf
PG_CONF_PATH="/etc/postgresql/$PG_VERSION/main/postgresql.conf"

echo "[pgtuned.sh] executing \"pgtune.sh$cmd_opts\""
bash pgtune.sh $cmd_opts > tuned.conf

echo "[pgtuned.sh] importing additional parameters from existing postgresql.conf"
while IFS= read -r line; do
  if [[ $line =~ ^[[:blank:]]*([^\#]*)\ =\ ([^[[:blank:]]\#\'\"]*|\'.*\'|\".*\")[[:blank:]]*(\#?.*)$ ]]; then
    key=${BASH_REMATCH[1]}
    value=${BASH_REMATCH[2]}
    outoftune[$key]=$value
  fi
done < "$PG_CONF_PATH"

while IFS= read -r line; do
  if [[ $line =~ ^([^\#]*)\ =\ (.*)$ ]]; then
    key=${BASH_REMATCH[1]}
    value=${BASH_REMATCH[2]}
    tuned[$key]=$value
  fi
done < tuned.conf

comment_line=0
for key in "${!outoftune[@]}"
do
  if [ ! "${tuned[$key]}" ]; then
    if [ "$comment_line" -eq 0 ]; then
      echo >> tuned.conf 
      echo "# Configuration parameters harvested from original postgresql.conf" >> tuned.conf
      echo >> tuned.conf
      comment_line=1
    fi
    echo $key" = "${outoftune[$key]} >> tuned.conf
  fi
done

# Backup the old configuration file
sudo cp "$PG_CONF_PATH" "${PG_CONF_PATH}.bak"

# Move the new configuration file
sudo mv tuned.conf "$PG_CONF_PATH"

# Set correct permissions
sudo chown postgres:postgres "$PG_CONF_PATH"
sudo chmod 600 "$PG_CONF_PATH"

echo "[pgtuned.sh] postgresql.conf has been successfully pgtuned"

# Restart PostgreSQL
sudo systemctl restart postgresql

echo "[pgtuned.sh] PostgreSQL has been restarted with new configuration"

# Check service status
sudo systemctl status postgresql

echo "[pgtuned.sh] Please check PostgreSQL logs for any errors"
echo "You can use: sudo tail -f /var/log/postgresql/postgresql-$PG_VERSION-main.log"
