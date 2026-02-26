#!/bin/bash
# RenaArt Setup Script
# Run this after cloning the repo

echo "🏛️ Setting up RenaArt..."

# Create asset directories
mkdir -p assets/images
mkdir -p assets/fonts

echo ""
echo "📦 Installing packages..."
flutter pub get

echo ""
echo "⚠️  IMPORTANT: Font Setup Required"
echo "========================================"
echo "Download these fonts and place them in assets/fonts/:"
echo ""
echo "Cormorant (Google Fonts):"
echo "  → https://fonts.google.com/specimen/Cormorant"
echo "  Files needed:"
echo "    - Cormorant-Regular.ttf"
echo "    - Cormorant-Italic.ttf"  
echo "    - Cormorant-SemiBold.ttf"
echo "    - Cormorant-Bold.ttf"
echo ""
echo "Jost (Google Fonts):"
echo "  → https://fonts.google.com/specimen/Jost"
echo "  Files needed:"
echo "    - Jost-Regular.ttf"
echo "    - Jost-Medium.ttf"
echo "    - Jost-Light.ttf"
echo ""
echo "OR use the Google Fonts package instead:"
echo "  Add 'google_fonts: ^6.1.0' to pubspec.yaml"
echo "  and update AppTheme to use GoogleFonts.cormorant() / GoogleFonts.jost()"
echo ""
echo "========================================"
echo ""
echo "🚀 After adding fonts, run: flutter run"
echo ""
echo "💡 Tip: The app works without fonts but will use system fonts."
echo "   Add fonts for the full museum aesthetic experience."
