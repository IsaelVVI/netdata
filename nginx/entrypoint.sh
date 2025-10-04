#!/bin/sh
# Script para configurar Nginx com autenticação a partir de variáveis de ambiente

set -e

echo "🔧 Configurando Netdata com autenticação..."

# Verificar se as variáveis estão definidas
if [ -z "$NETDATA_PASSWORD" ]; then
    echo "❌ ERRO: NETDATA_PASSWORD não está definida!"
    echo "Por favor, defina as variáveis de ambiente:"
    echo "  NETDATA_USER (padrão: admin)"
    echo "  NETDATA_PASSWORD (obrigatório)"
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

# Gerar configuração do Nginx
echo "📝 Gerando configuração do Nginx..."
cat > /etc/nginx/nginx.conf << 'NGINX_EOF'
events {
    worker_connections 1024;
}

http {
    upstream netdata {
        server netdata:19999;
        keepalive 64;
    }

    server {
        listen 80;
        server_name _;

        # Autenticação básica
        auth_basic "Área Restrita - Netdata";
        auth_basic_user_file /etc/nginx/.htpasswd;

        location / {
            proxy_pass http://netdata;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Connection "keep-alive";
            proxy_store off;
        }

        # WebSocket support para gráficos em tempo real
        location /api/v1/info {
            proxy_pass http://netdata;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
NGINX_EOF

echo "✅ Autenticação configurada para o usuário: $NETDATA_USER"
echo "🚀 Nginx configurado e pronto para iniciar!"

