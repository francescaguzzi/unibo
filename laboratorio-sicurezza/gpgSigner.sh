#!/bin/bash

# This script is used to sign a file with a GPG key.

# Usage: gpgSigner.sh <file> <Name> <Surname> <email> <passphrase>
if [ $# -ne 5 ]; then
    echo "Usage: gpgSigner.sh <file> <Name> <Surname> <email> <passphrase>"
    exit 1
fi

file_path=$1
name=$2
surname=$3
email=$4
passphrase=$5

# Generate a gpg signature for the file set to expire in 2 years
gpg --batch --gen-key <<EOF
%echo Generating a basic OpenPGP RSA key
Key-Type: RSA
Key-Length: 2048
Name-Real: $name $surname
Name-Email: $email
Expire-Date: 2y
Passphrase: $passphrase
%commit
%echo done
EOF

# Sign the file with the generated key
gpg --local-user "$name $surname <$email>" --sign "$file_path" 

if [ $? -eq 0 ]; then
    echo "File signed successfully."
else
    echo "File signing failed."
fi

# Copy the public key to the current directory
gpg --armor --export "$name $surname <$email>" > "${name}_${surname}.pub"

if [ $? -eq 0 ]; then
    echo "Public key exported successfully."
else
    echo "Public key export failed."
fi
