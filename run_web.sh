#!/usr/bin/env bash
# run_web.sh — Arranca Flutter web en el puerto 3000
#
# Razón de ser: Firebase Studio intercepta el puerto asignado por $PORT
# (normalmente 9002) con su propio proxy de autenticación. Esto redirige
# los requests de login a forwardAuthCookie?redirectToken=... antes de
# que lleguen al backend.
#
# El puerto 3000 no está interceptado por Firebase Studio, así que los
# requests de red llegan directamente al backend sin pasar por el proxy.
#
# Uso:
#   chmod +x run_web.sh
#   ./run_web.sh
#
# Para debug (hot reload no funciona en Firebase Studio por mixed-content,
# pero sí en Chrome local):
#   ./run_web.sh --debug

MODE="--profile"
if [[ "$1" == "--debug" ]]; then
  MODE=""
fi

flutter run \
  -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 3000 \
  $MODE
