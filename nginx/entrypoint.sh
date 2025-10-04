#!/bin/sh
# Script para gerar .htpasswd a partir de variáveis de ambiente

set -e

# Verificar se as variáveis estão definidas
if [ -z "$NETDATA_PASSWORD" ]; then
    echo "❌ ERRO: NETDATA_PASSWORD não está definida!"
    echo "Por favor, defina a variável de ambiente NETDATA_PASSWORD"
    exit 1
fi

# Instalar apache2-utils se não estiver instalado (para ter htpasswd)
if ! command -v htpasswd > /dev/null 2>&1; then
    echo "📦 Instalando apache2-utils..."
    apk add --no-cache apache2-utils
fi

# Gerar o arquivo .htpasswd
echo "🔐 Gerando arquivo de autenticação..."
htpasswd -cb /etc/nginx/.htpasswd "$NETDATA_USER" "$NETDATA_PASSWORD"

echo "✅ Autenticação configurada para o usuário: $NETDATA_USER"
echo "🚀 Iniciando Nginx..."

