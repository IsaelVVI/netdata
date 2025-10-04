# 📊 Netdata - Monitoramento de Servidor

Este projeto implementa uma solução completa de monitoramento de sistema usando **Netdata** com Docker Compose, ideal para implantação em VPS ou servidores locais.

> 🚀 **Usando Coolify?** Este projeto está otimizado para deploy no Coolify!  
> Consulte o guia completo: **[COOLIFY-SETUP.md](COOLIFY-SETUP.md)**

## 📖 O que é Netdata?

Netdata é uma ferramenta poderosa de monitoramento em tempo real que permite visualizar métricas do sistema, recursos e performance do servidor. Oferece:

- ⚡ **Monitoramento em tempo real** com atualizações por segundo
- 📈 **Métricas detalhadas** de CPU, memória, disco, rede e processos
- 🐳 **Monitoramento de containers Docker** incluindo nomes e estatísticas
- 🎯 **Dashboard interativo** e intuitivo
- 🔔 **Sistema de alertas** configurável
- 💾 **Armazenamento de dados históricos** para análise

## 🚀 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/) (versão 20.10 ou superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versão 1.27 ou superior)
- Acesso SSH ao servidor (para implantação remota)

## 📁 Estrutura do Projeto

```
netdata/
├── docker-compose.yaml     # Configuração principal do Docker
├── netdata/
│   └── netdata.conf       # Configurações customizadas do Netdata
├── nginx/
│   ├── nginx.conf         # Configuração do Nginx (reverse proxy)
│   └── .htpasswd          # Arquivo de senhas (gerado por você)
├── setup-auth.sh          # Script para configurar autenticação (Linux)
├── setup-auth.ps1         # Script para configurar autenticação (Windows)
└── README.md              # Este arquivo
```

## ⚙️ Configuração

### Docker Compose

O arquivo `docker-compose.yml` está configurado com:

- **Imagem**: `netdata/netdata:v1.47.4`
- **Porta**: `19999` (interface web do Netdata)
- **Volumes**:
  - Configurações personalizadas em `./netdata/config`
  - Dados históricos persistentes em `netdata_lib`
  - Cache para melhor performance em `netdata_cache`
  - Métricas do sistema montadas de `/proc` e `/sys`
  - Socket do Docker para monitoramento de containers

### Configuração do Netdata

O arquivo `netdata/netdata.conf` inclui otimizações para:

- **Modo de memória**: `save` - Minimiza uso de RAM salvando dados em disco
- **Web mode**: `static-threaded` - Otimizado para sistemas multi-core
- **Health monitoring**: Ativado para alertas e monitoramento de saúde
- **Logging**: Desabilitado para ambientes de produção

## 🔐 Configuração de Segurança (IMPORTANTE!)

Este projeto está configurado com **autenticação obrigatória** usando Nginx. Você precisa configurar usuário e senha antes de iniciar.

> 💡 **Para usuários do Coolify:** Siga as instruções específicas no [COOLIFY-SETUP.md](COOLIFY-SETUP.md) que explica como configurar a autenticação diretamente no servidor antes do deploy.

### Configurar Autenticação

#### No Linux/VPS (Recomendado):

```bash
# Tornar o script executável
chmod +x setup-auth.sh

# Executar o script
./setup-auth.sh
```

O script irá:
1. Solicitar um nome de usuário
2. Solicitar uma senha (será digitada de forma segura)
3. Criar o arquivo `nginx/.htpasswd` com suas credenciais

#### No Windows (PowerShell):

```powershell
.\setup-auth.ps1
```

#### Método Manual (se os scripts não funcionarem):

```bash
# Usando Docker (funciona em qualquer sistema)
docker run --rm -i httpd:alpine htpasswd -nbB seu-usuario sua-senha > nginx/.htpasswd
```

Substitua `seu-usuario` e `sua-senha` pelas suas credenciais.

## 🎯 Como Usar

> 🚀 **Deploy no Coolify:** Se você está usando Coolify, ignore esta seção e siga o [COOLIFY-SETUP.md](COOLIFY-SETUP.md).

### 1. Iniciar o Netdata

**Após configurar a autenticação**, no diretório do projeto, execute:

```bash
docker-compose up -d
```

Isso irá:
- Baixar as imagens do Netdata e Nginx (se necessário)
- Criar os volumes persistentes
- Iniciar os containers em modo daemon com proteção por senha

### 2. Verificar o Status

Confirme que o container está rodando:

```bash
docker-compose ps
```

Você deve ver o container `netdata` com status `Up`.

### 3. Acessar o Dashboard

**🔑 Uma tela de login será exibida solicitando as credenciais que você configurou!**

#### Acesso Local

Se estiver rodando localmente, acesse:
```
http://localhost:19999
```

Digite o usuário e senha que você configurou no `setup-auth.sh`.

#### Acesso Remoto no VPS

**Opção 1: Acesso Direto via IP (se porta estiver aberta no firewall)**

```
http://IP-DO-SEU-VPS:19999
```

**Opção 2: Acesso via SSH Tunnel (Mais Seguro)**

Se a porta 19999 estiver fechada no firewall (recomendado), use SSH tunnel:

```bash
ssh -L 19999:localhost:19999 usuario@ip-do-servidor
```

Depois acesse:
```
http://localhost:19999
```

Substitua:
- `usuario` pelo seu nome de usuário do servidor
- `ip-do-servidor` pelo IP do seu VPS

### 4. Verificar Health Check

O Netdata possui um health check automático configurado. Para verificar:

```bash
docker-compose logs netdata
```

## 📊 Recursos Monitorados

O Netdata monitora automaticamente:

- ✅ **CPU**: Uso geral, por core, frequência
- ✅ **Memória**: RAM, swap, cache
- ✅ **Disco**: I/O, espaço usado, latência
- ✅ **Rede**: Tráfego, pacotes, erros
- ✅ **Processos**: Top processos por CPU e memória
- ✅ **Containers Docker**: Uso de recursos por container
- ✅ **Sistema**: Load average, uptime, temperatura

## 🔧 Comandos Úteis

### Parar o Netdata
```bash
docker-compose down
```

### Reiniciar o Netdata
```bash
docker-compose restart
```

### Ver logs em tempo real
```bash
docker-compose logs -f netdata
```

### Atualizar para nova versão
```bash
docker-compose pull
docker-compose up -d
```

### Remover completamente (incluindo volumes)
```bash
docker-compose down -v
```

## 🔔 Próximos Passos

Para expandir este projeto, você pode:

1. **Adicionar Alertas no Discord**
   - Configure webhooks para receber notificações de alertas críticos

2. **Integração com Grafana**
   - Visualize dados do Netdata em dashboards customizados do Grafana

3. **Configurar domínio com Cloudflare**
   - Exponha o dashboard de forma segura usando Cloudflare Tunnel

4. **Implementar autenticação**
   - Adicione OAuth ou autenticação básica para proteger o acesso

5. **Coolify**
   - Implante usando Coolify com integração GitHub para deploy automático

6. **Personalizar alertas**
   - Configure limites personalizados para CPU, memória e disco

## 🛡️ Segurança

### ✅ Proteções Implementadas

Este projeto JÁ inclui:
- ✅ **Autenticação obrigatória** via Nginx com usuário e senha
- ✅ **Reverse proxy** isolando o Netdata da rede pública
- ✅ **Rede interna Docker** impedindo acesso direto ao Netdata
- ✅ **Criptografia bcrypt** para senhas

### 🔒 Recomendações Adicionais

Para segurança máxima no VPS:

#### 1. Configurar Firewall (UFW)

```bash
# Permitir apenas SSH
sudo ufw allow 22/tcp

# Permitir Netdata apenas de IPs específicos (opcional)
sudo ufw allow from SEU_IP_CASA to any port 19999

# Ativar firewall
sudo ufw enable
```

#### 2. Usar Apenas SSH Tunnel (Mais Seguro)

Não abra a porta 19999 no firewall. Acesse sempre via SSH:

```bash
ssh -L 19999:localhost:19999 usuario@vps
```

Assim o Netdata fica **totalmente invisível** na internet!

#### 3. Trocar a Senha

Para atualizar a senha:

```bash
# Remover arquivo antigo
rm nginx/.htpasswd

# Executar novamente
./setup-auth.sh

# Reiniciar containers
docker-compose restart
```

#### 4. Verificar Acessos

Monitore tentativas de login no nginx:

```bash
docker-compose logs nginx | grep "401\|403"
```

## 📚 Documentação Adicional

- [Documentação Oficial do Netdata](https://learn.netdata.cloud/)
- [Configuração Avançada](https://learn.netdata.cloud/docs/configuring/configuration)
- [Configurar Alertas](https://learn.netdata.cloud/docs/alerting/notifications)
- [API do Netdata](https://learn.netdata.cloud/docs/rest-api)

## 🐛 Troubleshooting

### Erro: "Authentication required" não aparece

```bash
# Verificar se o arquivo de senha existe
ls -la nginx/.htpasswd

# Se não existir, execute:
./setup-auth.sh

# Reiniciar containers
docker-compose restart
```

### Senha não funciona

```bash
# Recriar arquivo de senha
rm nginx/.htpasswd
./setup-auth.sh

# Forçar recriação dos containers
docker-compose down
docker-compose up -d
```

### Container não inicia
```bash
# Verificar logs do Netdata
docker-compose logs netdata

# Verificar logs do Nginx
docker-compose logs nginx

# Verificar permissões do Docker socket
ls -la /var/run/docker.sock
```

### Dashboard não carrega após login

```bash
# Verificar se ambos containers estão rodando
docker-compose ps

# Deve mostrar netdata e nginx como "Up"

# Testar acesso interno
docker exec netdata curl localhost:19999
```

### Problemas de permissão
```bash
# Garantir que o usuário está no grupo docker
sudo usermod -aG docker $USER
# Fazer logout e login novamente
```

### Esqueci minha senha

```bash
# Recriar credenciais
rm nginx/.htpasswd
./setup-auth.sh
docker-compose restart nginx
```

## 📄 Licença

Este projeto utiliza Netdata, que é open-source sob a licença GPL v3+.

## 👤 Autor

Baseado no tutorial: "How to deploy monitoring on your VPS with Coolify and Netdata"

---

⭐ Se este projeto foi útil, considere dar uma estrela no repositório!

