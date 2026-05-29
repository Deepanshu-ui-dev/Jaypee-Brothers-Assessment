#!/bin/bash

# Download Flutter
echo "Downloading Flutter..."
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable
fi
export PATH="$PATH:`pwd`/flutter/bin"

# Generate .env file using Vercel environment variables
echo "Generating .env file..."
cat <<EOF > .env
FIREBASE_API_KEY=$FIREBASE_API_KEY
FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN
FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET
FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
FIREBASE_APP_ID=$FIREBASE_APP_ID
EOF

# Build Web
echo "Fetching dependencies and building..."
flutter pub get
flutter build web --release

echo "Build complete! Output is in build/web/"
