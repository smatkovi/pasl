#!/bin/bash
# XFOIL Vergleichsscript für Hess-Smith Panelverfahren
# Benötigt: xfoil, xvfb (für headless Ausführung)
#
# Installation (Ubuntu/Debian):
#   sudo apt-get install xfoil xvfb xfonts-base xfonts-75dpi xfonts-100dpi
#
# Ausführung:
#   chmod +x run_xfoil_comparison.sh
#   ./run_xfoil_comparison.sh

echo "=== XFOIL Vergleich für NACA 0012 (inviscid) ==="
echo ""

# XFOIL mit virtuellem Framebuffer ausführen
xvfb-run -a xfoil << 'EOF'
NACA 0012
PANE
OPER
PACC
polar_xfoil.txt

ALFA 0
ALFA 2
ALFA 5
ALFA 10
PACC

QUIT
EOF

echo ""
echo "=== XFOIL Ergebnisse ==="
cat polar_xfoil.txt

echo ""
echo "=== Fertig ==="
echo "Die Ergebnisse wurden in polar_xfoil.txt gespeichert."
