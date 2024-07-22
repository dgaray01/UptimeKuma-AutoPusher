#!/bin/bash

# Print a welcome message
echo "Uptime-Kuma Auto push"
echo "Thank you for using this script."

# Ask for the Push URL
read -p "Enter the Push URL: " URL

# Generate a random 5-digit PIN
PIN=$((10000 + RANDOM % 90000))

# Create the folder at /etc/uptimekumapush
mkdir -p /etc/uptimekumapush

# Verify if a file with the PIN exists
while [[ -e "/etc/uptimekumapush/$PIN.sh" ]]; do
    PIN=$((10000 + RANDOM % 90000))
done

# Create the file with the PIN and extension .sh
echo "#!/bin/bash" > "/etc/uptimekumapush/$PIN.sh"
echo "" >> "/etc/uptimekumapush/$PIN.sh"
echo "# URL for the Passive Monitor Push" >> "/etc/uptimekumapush/$PIN.sh"
echo "URL=\"$URL\"" >> "/etc/uptimekumapush/$PIN.sh"
echo "" >> "/etc/uptimekumapush/$PIN.sh"
echo "# Send the Passive Monitor Push using curl" >> "/etc/uptimekumapush/$PIN.sh"
echo "curl -X GET \"\$URL\"" >> "/etc/uptimekumapush/$PIN.sh"

# Make the file executable
chmod +x "/etc/uptimekumapush/$PIN.sh"

# Add the crontab entry
(crontab -l ; echo "*/1 * * * * /etc/uptimekumapush/$PIN.sh") | crontab -

# Log setup completion
echo "Setup finished correctly. PIN: $PIN"
