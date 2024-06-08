# pfSense Backup Script

This script automates the process of backing up the configuration of a pfSense firewall. It logs into the pfSense web interface, retrieves the configuration file, and uploads it to OneDrive using `rclone`.

## Prerequisites

Before using this script, make sure you have the following:

1. **curl**: To interact with the pfSense web interface.
2. **rclone**: To upload the backup file to OneDrive.
3. **Access to pfSense**: Ensure you have the correct IP/hostname, port, username, and password for your pfSense instance.

## Usage

1. **Clone the Repository**:
    ```sh
    git clone https://github.com/SrOlalau/pfsense_backup_cloud
    cd pfsense_backup_cloud
    ```

2. **Modify Script Variables**:
   Edit the script and replace the placeholder values with your actual pfSense details.

    ```sh
    PFSENSE_IP="pfsense.example.com"  # Replace with your pfSense IP or hostname
    PFSENSE_PORT="8443"  # Replace with your pfSense web interface port
    PFSENSE_USER="your_username"  # Replace with your pfSense username
    PFSENSE_PASSWORD="your_password"  # Replace with your pfSense password
    ```

3. **Set Up rclone**:
   Ensure that `rclone` is configured to connect to your OneDrive account. Follow the [rclone configuration guide](https://rclone.org/onedrive/) if you haven't done this yet.

4. **Run the Script**:
    ```sh
    ./pfsense_backup.sh
    ```

## Script Explanation

### Variables

- **User-Defined Variables**:
    - `PFSENSE_IP`: The IP address or hostname of your pfSense instance.
    - `PFSENSE_PORT`: The port number of the pfSense web interface.
    - `PFSENSE_USER`: Your pfSense username.
    - `PFSENSE_PASSWORD`: Your pfSense password.

- **Static Variables**:
    - `CURRENT_DATE`: Current date and time for timestamping backup files.
    - `CURRENT_YEAR`, `CURRENT_MONTH`, `CURRENT_WEEK`: Used to create a hierarchical directory structure for backups.
    - `BACKUP_ROOT_DIR`: Root directory for storing backups.
    - `BACKUP_DIR`: Full path of the backup directory.
    - `BACKUP_FILE`: Full path of the backup file.
    - `COOKIE_FILE`, `CSRF_FILE`: Temporary files for storing cookies and CSRF tokens.

### Main Steps

1. **Create Backup Directory**:
    - Creates the backup directory structure if it doesn't already exist.

2. **Retrieve CSRF Token and Cookies**:
    - Uses `curl` to get the CSRF token and store cookies.

3. **Log in to pfSense**:
    - Logs into the pfSense web interface using the credentials and CSRF token.

4. **Download Configuration File**:
    - Retrieves the configuration file from pfSense and saves it to the backup directory.

5. **Clean Up**:
    - Removes temporary files used for storing cookies and CSRF tokens.

6. **Upload to OneDrive**:
    - Uses `rclone` to copy the backup file to OneDrive.

7. **Notification**:
    - Sends a notification if the `rclone` operation fails.

## Notifications

The script includes a notification function that can send alerts if the `rclone` operation fails. This function checks for a specific notification script located at `/usr/local/emhttp/webGui/scripts/notify`.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
