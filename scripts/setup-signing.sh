#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# scripts/setup-signing.sh
# Local one-time setup: generate a release keystore and create key.properties
# Run once from the repo root: bash scripts/setup-signing.sh
# ─────────────────────────────────────────────────────────────────────────────
set -e

KEYSTORE_PATH="renaart/renaart-release.jks"
KEY_PROPS_PATH="renaart/android/key.properties"

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║         RenaArt — Release Signing Setup              ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# Check java/keytool is available
if ! command -v keytool &> /dev/null; then
  echo "❌  keytool not found. Install JDK 17+."
  exit 1
fi

if [ -f "$KEYSTORE_PATH" ]; then
  echo "⚠️   Keystore already exists at $KEYSTORE_PATH — skipping generation."
else
  echo "📝  Enter details for your release keystore."
  read -rp "   Key alias (e.g. renaart-key): " KEY_ALIAS
  read -rsp "  Store password (min 6 chars):  " STORE_PASS; echo
  read -rsp "  Key password   (min 6 chars):  " KEY_PASS; echo
  read -rp "   First & Last Name:             " NAME
  read -rp "   Organisation:                  " ORG
  read -rp "   City:                          " CITY
  read -rp "   Country code (e.g. TH):        " COUNTRY

  keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=$NAME, O=$ORG, L=$CITY, C=$COUNTRY"

  echo ""
  echo "✅  Keystore created at $KEYSTORE_PATH"

  # Write key.properties
  cat > "$KEY_PROPS_PATH" <<EOF
storePassword=${STORE_PASS}
keyPassword=${KEY_PASS}
keyAlias=${KEY_ALIAS}
storeFile=../renaart-release.jks
EOF
  echo "✅  key.properties written to $KEY_PROPS_PATH"
fi

echo ""
echo "══════════════════════════════════════════════════════"
echo "  NEXT: Add these 4 secrets to GitHub Actions"
echo "  (Settings → Secrets and variables → Actions)"
echo ""
echo "  KEYSTORE_BASE64"
echo "    $(base64 -w 0 "$KEYSTORE_PATH" 2>/dev/null || base64 "$KEYSTORE_PATH")"
echo ""
echo "  KEYSTORE_PASSWORD   your store password"
echo "  KEY_PASSWORD        your key password"
echo "  KEY_ALIAS           your key alias"
echo ""
echo "  GOOGLE_PLAY_JSON_KEY"
echo "    → Create service account in Google Play Console:"
echo "      Setup → API access → Create service account"
echo "      Grant 'Release manager' role → Download JSON"
echo "      Paste the entire JSON content as the secret value"
echo "══════════════════════════════════════════════════════"
echo ""
echo "⚠️  DO NOT commit renaart-release.jks or key.properties"
echo "   Both are blocked by .gitignore"
echo ""
