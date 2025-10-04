#!/bin/bash

# Script para configurar autenticação do Netdata
# Este script cria o arquivo de senha para proteger o acesso

echo "========================================="
echo "   Configuração de Autenticação Netdata"
echo "========================================="
echo ""

# Verificar se o diretório existe
mkdir -p nginx

# Solicitar usuário
read -p "Digite o nome de usuário: " USERNAME

# Verificar se htpasswd está instalado
if ! command -v htpasswd &> /dev/null; then
    echo ""
    echo "❌ htpasswd não encontrado!"
    echo ""
    echo "Instalando apache2-utils..."
    
    # Detectar sistema operacional
    if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y apache2-utils
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y httpd-tools
    else
        echo "Sistema operacional não suportado automaticamente."
        echo "Por favor, instale manualmente:"
        echo "  - Ubuntu/Debian: sudo apt-get install apache2-utils"
        echo "  - CentOS/RHEL: sudo yum install httpd-tools"
        exit 1
    fi
fi

# Criar arquivo de senha
echo ""
echo "Criando senha para o usuário '$USERNAME'..."
htpasswd -c nginx/.htpasswd "$USERNAME"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Autenticação configurada com sucesso!"
    echo ""
    echo "Próximos passos:"
    echo "1. Execute: docker-compose up -d"
    echo "2. Acesse: http://localhost:19999 (ou IP do seu VPS)"
    echo "3. Use o usuário '$USERNAME' e a senha que você definiu"
    echo ""
else
    echo ""
    echo "❌ Erro ao criar arquivo de autenticação"
    exit 1
fi

