#!/bin/bash

# Variables to modify
PFSENSE_IP="pfsense.example.com"  # Replace with your pfSense IP or hostname
PFSENSE_PORT="8443"  # Replace with your pfSense web interface port
PFSENSE_USER="your_username"  # Replace with your pfSense username
PFSENSE_PASSWORD="your_password"  # Replace with your pfSense password

# Static variables
CURRENT_DATE=$(date +%Y-%m-%d_%H-%M-%S)  # Current date and time for timestamping backup files
CURRENT_YEAR=$(date +%Y)  # Current year
CURRENT_MONTH=$(date +%m)  # Current month
CURRENT_WEEK=$(date +%V)  # Current week number
BACKUP_ROOT_DIR="/mnt/cache/backups_pfsense"  # Root directory for backups
BACKUP_DIR="${BACKUP_ROOT_DIR}/${CURRENT_YEAR}/${CURRENT_MONTH}/${CURRENT_WEEK}"  # Backup directory structure based on current date
BACKUP_FILE="${BACKUP_DIR}/pfsense_config_backup_${CURRENT_DATE}.xml"  # Backup file name
COOKIE_FILE="/tmp/pfsense_cookies.txt"  # Temporary file to store cookies
CSRF_FILE="/tmp/pfsense_csrf.txt"  # Temporary file to store CSRF token

# Create the backup directory if it doesn't exist
mkdir -p ${BACKUP_DIR}

# Get CSRF token and cookies
curl -L -k --cookie-jar ${COOKIE_FILE} \
    https://${PFSENSE_IP}:${PFSENSE_PORT}/ \
    | grep "name='__csrf_magic'" \
    | sed 's/.*value="\([^"]*\)".*/\1/' > ${CSRF_FILE}

# Log in to pfSense
curl -L -k --cookie ${COOKIE_FILE} --cookie-jar ${COOKIE_FILE} \
    --data-urlencode "login=Login" \
    --data-urlencode "usernamefld=${PFSENSE_USER}" \
    --data-urlencode "passwordfld=${PFSENSE_PASSWORD}" \
    --data-urlencode "__csrf_magic=$(cat ${CSRF_FILE})" \
    https://${PFSENSE_IP}:${PFSENSE_PORT}/index.php > /dev/null

# Get a new CSRF token
curl -L -k --cookie ${COOKIE_FILE} --cookie-jar ${COOKIE_FILE} \
    https://${PFSENSE_IP}:${PFSENSE_PORT}/diag_backup.php \
    | grep "name='__csrf_magic'" \
    | sed 's/.*value="\([^"]*\)".*/\1/' > ${CSRF_FILE}

# Download the configuration file with all additional data
curl -L -k --cookie ${COOKIE_FILE} --cookie-jar ${COOKIE_FILE} \
    --data-urlencode "download=download" \
    --data-urlencode "backupdata=yes" \
    --data-urlencode "backupssh=yes" \
    --data-urlencode "__csrf_magic=$(cat ${CSRF_FILE})" \
    https://${PFSENSE_IP}:${PFSENSE_PORT}/diag_backup.php > ${BACKUP_FILE}

# Clean up temporary files
rm ${COOKIE_FILE} ${CSRF_FILE}

# Notification function
notify() {
  local title="$1"
  local message="$2"
  local source_path="$3"
  echo "$message"
  if [[ -f /usr/local/emhttp/webGui/scripts/notify ]]; then
    /usr/local/emhttp/webGui/scripts/notify -i "$([[ $message == Error* ]] && echo alert || echo normal)" -s "$title ($source_path)" -d "$message" -m "$message"
  fi
}

# Paths for rclone
SRC_PATH="/mnt/cache/backups_pfsense/"
DESTINATION="onedrive_personal:Backups/Pfsense/"

# Perform rclone operation
rclone copy "$SRC_PATH" "$DESTINATION" -P

# Check the result and send a notification
if [ $? -ne 0 ]; then
    notify "Rclone Backup Notification" "Failed backup of pfSense to OneDrive"
fi
