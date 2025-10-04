# 📊 Netdata - Monitoramento de Servidor

Este projeto implementa uma solução completa de monitoramento de sistema usando **Netdata** com Docker Compose, ideal para implantação em VPS ou servidores locais.

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
├── docker-compose.yml      # Configuração principal do Docker
├── netdata/
│   └── netdata.conf       # Configurações customizadas do Netdata
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

## 🎯 Como Usar

### 1. Iniciar o Netdata

No diretório do projeto, execute:

```bash
docker-compose up -d
```

Isso irá:
- Baixar a imagem do Netdata (se necessário)
- Criar os volumes persistentes
- Iniciar o container em modo daemon

### 2. Verificar o Status

Confirme que o container está rodando:

```bash
docker-compose ps
```

Você deve ver o container `netdata` com status `Up`.

### 3. Acessar o Dashboard

#### Acesso Local

Se estiver rodando localmente, acesse:
```
http://localhost:19999
```

#### Acesso via SSH (VPS/Servidor Remoto)

Para acessar o dashboard de um servidor remoto, use port forwarding:

```bash
ssh -L 19999:localhost:19999 usuario@ip-do-servidor
```

Substitua:
- `usuario` pelo seu nome de usuário do servidor
- `ip-do-servidor` pelo IP do seu VPS

Após conectar, acesse no seu navegador:
```
http://localhost:19999
```

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

**⚠️ IMPORTANTE**: O dashboard do Netdata expõe informações sensíveis do sistema.

Recomendações:
- Não exponha a porta 19999 publicamente sem autenticação
- Use VPN ou SSH tunnel para acesso remoto
- Configure firewall para restringir acesso
- Considere usar reverse proxy com autenticação (nginx, Traefik)

## 📚 Documentação Adicional

- [Documentação Oficial do Netdata](https://learn.netdata.cloud/)
- [Configuração Avançada](https://learn.netdata.cloud/docs/configuring/configuration)
- [Configurar Alertas](https://learn.netdata.cloud/docs/alerting/notifications)
- [API do Netdata](https://learn.netdata.cloud/docs/rest-api)

## 🐛 Troubleshooting

### Container não inicia
```bash
# Verificar logs
docker-compose logs netdata

# Verificar permissões do Docker socket
ls -la /var/run/docker.sock
```

### Dashboard não carrega
```bash
# Verificar se o container está rodando
docker ps | grep netdata

# Testar acesso interno
docker exec netdata curl localhost:19999
```

### Problemas de permissão
```bash
# Garantir que o usuário está no grupo docker
sudo usermod -aG docker $USER
# Fazer logout e login novamente
```

## 📄 Licença

Este projeto utiliza Netdata, que é open-source sob a licença GPL v3+.

## 👤 Autor

Baseado no tutorial: "How to deploy monitoring on your VPS with Coolify and Netdata"

---

⭐ Se este projeto foi útil, considere dar uma estrela no repositório!

