#!/bin/bash

# Function to generate a random 5-digit pin code
generate_pin() {
    echo $((RANDOM % 90000 + 10000))
}

# Print the welcome message
echo "###############################################"
echo "#                                             #"
echo "#      Uptime-Kuma Auto Push Script           #"
echo "#                                             #"
echo "###############################################"
echo
echo "Thank you for using this script!"
echo

# Ask for the Push URL
while true; do
    read -p "Please enter the Push URL: " PUSH_URL
    if [[ -n "$PUSH_URL" ]]; then
        break
    else
        echo "The Push URL cannot be empty. Please enter a valid URL."
    fi
done

# Ask for the Heartbeat interval and validate input
while true; do
    read -p "Please enter the Heartbeat interval in minutes (must be more than 1 minute): " HEARTBEAT_INTERVAL
    if [[ "$HEARTBEAT_INTERVAL" =~ ^[0-9]+$ ]] && [ "$HEARTBEAT_INTERVAL" -ge 1 ]; then
        break
    else
        echo "Invalid input. Please enter a digit greater than 1."
    fi
done

# Generate a unique 5-digit pin code and ensure response
PIN_CODE=""
while true; do
    PIN_CODE=$(generate_pin)
    if [[ -n "$PIN_CODE" ]]; then
        break
    fi
done

# Create the folder
FOLDER_PATH="/etc/uptimekumapush"
mkdir -p "$FOLDER_PATH"

# Ensure the PIN code is unique
while true; do
    FILE_PATH="$FOLDER_PATH/$PIN_CODE.sh"
    if [ ! -f "$FILE_PATH" ]; then
        break
    fi
    PIN_CODE=$(generate_pin)
done

# Create the script file with the provided URL
cat <<EOF > "$FILE_PATH"
#!/bin/bash

# URL for the Passive Monitor Push
URL="$PUSH_URL"

# Send the Passive Monitor Push using curl
curl -X GET "\$URL"
EOF

# Make the script executable
chmod +x "$FILE_PATH"

# Add a new cron job
(crontab -l 2>/dev/null; echo "*/$HEARTBEAT_INTERVAL * * * * $FILE_PATH") | crontab -

# Log everything
LOG_PATH="/var/log/uptimekumapush.log"
{
    echo "Setup started on $(date)"
    echo "Push URL: $PUSH_URL"
    echo "Heartbeat Interval: $HEARTBEAT_INTERVAL minutes"
    echo "Generated PIN Code: $PIN_CODE"
    echo "Script file created at: $FILE_PATH"
    echo "Cron job added: */$HEARTBEAT_INTERVAL * * * * $FILE_PATH"
    echo "Setup finished on $(date)"
} >> "$LOG_PATH"

# Final message
echo
echo "Setup finished correctly. All actions have been logged to $LOG_PATH."
