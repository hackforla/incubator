#!/usr/bin/env bash

# -----------------------------
# Created by Darren Pham
# github.com/darpham
# ------------------------------

# -----------------------------
# Import Github Public SSH Keys
# -----------------------------

cat <<"EOF" > /home/ubuntu/create_ssh_user_authorized_keys.sh
#!/usr/bin/env bash
set -e
SSH_USER=${ssh_user}
MARKER="# KEYS_BELOW_WILL_BE_UPDATED_BY_TERRAFORM"
KEYS_FILE=/home/$SSH_USER/.ssh/authorized_keys
GITHUB_SSH_USERNAMES_URL="https://raw.githubusercontent.com/${github_repo_owner}/${github_repo_name}/${github_branch}/${github_filepath}"
TEMP_GITHUB_KEYS_FILE=$(mktemp /tmp/github_ssh_keys.XXXXXX)
# TEMP_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXX)
PATH=/usr/local/bin:$PATH

# Add marker, if not present, and copy static content.
grep -Fxq "$MARKER" $KEYS_FILE || echo -e "\n$MARKER" >> $KEYS_FILE
line=$(grep -n "$MARKER" $KEYS_FILE | cut -d ":" -f 1)
# head -n $line $KEYS_FILE > $TEMP_KEYS_FILE

# Pull SSH public keys from Github
wget --output-document $TEMP_GITHUB_KEYS_FILE $GITHUB_SSH_USERNAMES_URL

# Create user and move authorized keys
for gh_user in $(grep "^[^#;]" $TEMP_GITHUB_KEYS_FILE); do
  if ! id "$gh_user" &>/dev/null; then
    useradd -m -d /home/$gh_user -s /bin/bash $gh_user
    install -d -m 700 -o $gh_user -g $gh_user /home/$gh_user/.ssh
    install -b -m 600 -o $gh_user -g $gh_user /dev/null /home/$gh_user/.ssh/authorized_keys
    install -b -m 600 -o $gh_user -g $gh_user /dev/null /home/$gh_user/.ssh/conf
    usermod -aG sudo $gh_user
  fi
  curl https://github.com/$gh_user.keys | tee -a /home/$gh_user/.ssh/authorized_keys
done
EOF

# Execute now
chmod 755 /home/ubuntu/create_ssh_user_authorized_keys.sh
su root -c /home/ubuntu/create_ssh_user_authorized_keys.sh

# Enable timestamp in History for all users
echo 'export HISTTIMEFORMAT="%F %T "' >> /etc/profile && source  /etc/profile

# -----------------------------
# Setup Cron Job
# -----------------------------

# Be backwards compatible with old cron update enabler
if [ "${enable_hourly_cron_updates}" = 'true' -a -z "${cron_key_update_schedule}" ]; then
  cron_key_update_schedule="0 * * * *"
else
  cron_key_update_schedule="${cron_key_update_schedule}"
fi

# Add to cron
if [ -n "$cron_key_update_schedule" ]; then
  croncmd="/home/ubuntu/create_ssh_user_authorized_keys.sh"
  cronjob="$cron_key_update_schedule $croncmd"
  ( crontab -u root -l | grep -v "$croncmd" ; echo "$cronjob" ) | crontab -u root -
fi

# Disable password requirement for sudoers
sed -i 's/sudo.*(ALL:ALL) ALL/sudo ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers


# Create New Record for Bastion
snap install jq
snap install aws-cli --classic
hosted_zone_id=$(aws route53 list-hosted-zones \
| jq --arg domain "${domain_name}." '.HostedZones[] | select(.Name==$domain) | .Id' \
| cut -d'/' -f3 | sed 's/.$//')

bastion_public_ip=$(curl http://checkip.amazonaws.com)

tee "/tmp/new_record.json" <<EOF
{
            "Comment": "",
            "Changes": [{
            "Action": "UPSERT",
                        "ResourceRecordSet": {
                                    "Name": "${bastion_hostname}",
                                    "Type": "A",
                                    "TTL": 300,
                                 "ResourceRecords": [{ "Value": "$bastion_public_ip"}]
}}]
}
EOF

aws route53 change-resource-record-sets \
--hosted-zone-id $hosted_zone_id \
--change-batch file:///tmp/new_record.json

# Append addition user-data script
${additional_user_data_script}
