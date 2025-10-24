#!/bin/bash
# Script to set up a quick OblivionOS demo

echo "🚀 Configuration de la démonstration OblivionOS..."

# Build the components
echo "Compilation des composants..."
cargo build --release --workspace

# Create a simple demo script that shows the components
cat > demo.sh << 'EOF'
#!/bin/bash
echo "🎉 Bienvenue dans OblivionOS !"
echo ""
echo "Composants disponibles :"
echo "- oblivion-shell: Interface utilisateur principale"
echo "- oblivion-panel: Barre des tâches"
echo "- oblivion-comp: Compositeur Wayland"
echo "- oblivion-session: Gestionnaire de session"
echo ""
echo "Pour lancer l'interface complète :"
echo "  ./oblivion-session"
echo ""
echo "Ou lancer individuellement :"
echo "  ./oblivion-comp &"
echo "  ./oblivion-panel &"
echo "  ./oblivion-shell &"
echo ""
echo "OblivionOS est un système d'exploitation basé sur Linux"
echo "avec une interface utilisateur entièrement développée en Rust !"
echo ""
echo "Architecture :"
echo "• Noyau : Linux"
echo "• Interface : Rust + Wayland"
echo "• Framework UI : Oblivion SDK (SwiftUI-like)"
echo ""
read -p "Appuyez sur Entrée pour continuer..."
EOF

chmod +x demo.sh

echo "✅ Démonstration configurée !"
echo ""
echo "Pour voir OblivionOS :"
echo "1. ./demo.sh (aperçu textuel)"
echo "2. ./target/release/oblivion-shell (interface graphique)"
echo ""
echo "L'image QEMU est prête pour une installation complète."