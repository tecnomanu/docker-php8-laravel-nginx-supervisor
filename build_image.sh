#!/bin/bash

# ========== Estilo ==========
GREEN="\\033[0;32m"
RED="\\033[0;31m"
BLUE="\\033[0;34m"
CYAN="\\033[0;36m"
YELLOW="\\033[1;33m"
RESET="\\033[0m"
BOLD="\\033[1m"
CHECKMARK="✔"
CROSSMARK="✖"
QUESTION="❓"
BUILD="🔧"
WAVE="🌊"
SPINNER=( '|' '/' '-' '\\\\' )

# ========== Banner ==========
clear
printf "${BLUE}${BOLD}\\n"
printf "╔════════════════════════════════════════════╗\\n"
printf "║        🚀 TecnoManu Laravel Builder 🚀        ║\\n"
printf "╚════════════════════════════════════════════╝\\n"
printf "${RESET}\\n"

# ========== Flags ==========
VERBOSE=false

for arg in "$@"; do
    if [ "$arg" == "-v" ]; then
        VERBOSE=true
    fi
done

# ========== Preguntas ==========
printf "${CYAN}${QUESTION} ¿Incluir soporte para MySQL? (y/n): ${RESET}"
read INCLUDE_MYSQL
printf "${CYAN}${QUESTION} ¿Incluir soporte para PostgreSQL? (y/n): ${RESET}"
read INCLUDE_PGSQL
printf "${CYAN}${QUESTION} ¿Incluir soporte para MongoDB? (y/n): ${RESET}"
read INCLUDE_MONGO
printf "${CYAN}${QUESTION} ¿Incluir Laravel Echo Server? (y/n): ${RESET}"
read INCLUDE_ECHO

# ========== Flags de build ==========
MYSQL_ARG="--build-arg INSTALL_MYSQL=false"
PGSQL_ARG="--build-arg INSTALL_PGSQL=false"
MONGO_ARG="--build-arg INSTALL_MONGO=false"
ECHO_ARG="--build-arg INSTALL_ECHO=false"
TAG_SUFFIX=""

if [[ "$INCLUDE_MYSQL" == "y" ]]; then
    MYSQL_ARG="--build-arg INSTALL_MYSQL=true"
    TAG_SUFFIX="${TAG_SUFFIX}-mysql"
fi
if [[ "$INCLUDE_PGSQL" == "y" ]]; then
    PGSQL_ARG="--build-arg INSTALL_PGSQL=true"
    TAG_SUFFIX="${TAG_SUFFIX}-pgsql"
fi
if [[ "$INCLUDE_MONGO" == "y" ]]; then
    MONGO_ARG="--build-arg INSTALL_MONGO=true"
    TAG_SUFFIX="${TAG_SUFFIX}-mongo"
fi
if [[ "$INCLUDE_ECHO" == "y" ]]; then
    ECHO_ARG="--build-arg INSTALL_ECHO=true"
    TAG_SUFFIX="${TAG_SUFFIX}-echo"
fi

if [[ "$TAG_SUFFIX" == "" ]]; then
    TAG_SUFFIX="-minimal"
fi

VERSION="8.3"
TAG="tecnomanu/laravel-runtime:${VERSION}${TAG_SUFFIX}"

# ========== Inicio build ==========
printf "\\n${YELLOW}${BUILD} Construyendo imagen: ${BOLD}${TAG}${RESET}\\n"

if [ "$VERBOSE" = true ]; then
    docker build $MYSQL_ARG $PGSQL_ARG $MONGO_ARG $ECHO_ARG -t $TAG .
else
    docker build $MYSQL_ARG $PGSQL_ARG $MONGO_ARG $ECHO_ARG -t $TAG . > build.log 2>&1 &
    PID=$!

    i=0
    printf "\\n${CYAN}⏳ Construyendo"
    while kill -0 $PID 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\\r${CYAN}⏳ Construyendo ${SPINNER[$i]}${RESET}"
        sleep 0.2
    done
    wait $PID
fi

# ========== Resultado ==========
if [ $? -eq 0 ]; then
    printf "\\r${GREEN}${CHECKMARK} Imagen construida correctamente: ${TAG}${RESET}\\n"
else
    printf "\\r${RED}${CROSSMARK} Error al construir la imagen. Revisa build.log${RESET}\\n"
fi