# 🚀 Guia de Configuração para Coolify

Este guia explica como fazer deploy do Netdata protegido por senha usando **Coolify**.

## 📋 Pré-requisitos

1. ✅ Coolify instalado e funcionando no seu VPS
2. ✅ Repositório GitHub (privado ou público) conectado ao Coolify
3. ✅ SSH habilitado no Coolify para este projeto

## 🔐 Passo 1: Configurar Autenticação

A autenticação é feita através de **variáveis de ambiente** no Coolify. Super simples! 🎉

### No Painel do Coolify:

1. Acesse seu projeto no Coolify
2. Vá na aba **Environment Variables** (ou **Settings**)
3. Adicione as seguintes variáveis:

| Variável | Valor | Exemplo |
|----------|-------|---------|
| `NETDATA_USER` | Seu usuário de login | `admin` |
| `NETDATA_PASSWORD` | Sua senha forte | `Netd@t@2024!Segura` |

4. Clique em **Save**

**✅ Pronto!** Não precisa criar arquivos manualmente ou usar SSH!

**💡 Dica de Segurança:** Use senhas fortes como:
- ✅ `Admin2024!@Netdata`
- ✅ `Monitor#Seguro$2024`
- ❌ `123456` ou `admin`

---

## 🎯 Passo 2: Deploy no Coolify

### 2.1. Criar Novo Recurso

1. No Coolify, vá em **Projects** → Seu projeto
2. Clique em **+ New Resource**
3. Selecione **Private GitHub Repository** (ou Public)
4. Escolha seu repositório

### 2.2. Configurar o Build

1. **Build Pack:** Selecione `Docker Compose`
2. **Docker Compose Location:** Deixe como `docker-compose.yaml` (se estiver na raiz)
3. **Base Directory:** `/` (raiz do repositório)

### 2.3. Configurar Rede e Domínio

**Importante:** O Coolify vai detectar a porta `19999` do nginx.

Você tem duas opções:

#### Opção 1: Com Domínio Público (Recomendado)

1. Na seção **Domains**, adicione um domínio:
   - Exemplo: `netdata.seudominio.com`
   - O Coolify vai automaticamente:
     - Configurar o proxy reverso
     - Gerar certificado SSL (Let's Encrypt)
     - Redirecionar HTTP → HTTPS

2. Configure seu DNS para apontar para o IP do VPS:
   ```
   netdata.seudominio.com  A  IP-DO-SEU-VPS
   ```

#### Opção 2: Sem Domínio (Acesso via IP:Porta)

1. Deixe a seção **Domains** vazia
2. O Coolify vai expor na porta `19999`
3. Acesse via: `http://IP-DO-VPS:19999`

### 2.4. Configurações Adicionais (Opcional)

**Environment Variables:** Não são necessárias para a configuração básica.

**Volumes:** O Coolify vai gerenciar automaticamente os volumes definidos no docker-compose.

## 🚀 Passo 3: Fazer Deploy

1. Clique no botão **Deploy** (ícone de foguete 🚀)
2. Aguarde o build e deploy (pode levar 2-5 minutos)
3. Monitore os logs na aba **Deployment Logs**

## ✅ Passo 4: Verificar e Acessar

### Verificar Status

1. No Coolify, vá na aba **Containers**
2. Você deve ver 2 containers rodando:
   - `netdata` - Status: Running
   - `nginx` - Status: Running

### Acessar o Dashboard

**Com Domínio:**
```
https://netdata.seudominio.com
```

**Sem Domínio:**
```
http://IP-DO-VPS:19999
```

Uma tela de login vai aparecer pedindo:
- **Usuário:** O que você definiu no htpasswd
- **Senha:** A senha que você definiu

## 🔧 Troubleshooting no Coolify

### Erro: "NETDATA_PASSWORD não está definida"

As variáveis de ambiente não foram configuradas no Coolify.

**Solução:**
1. Vá em **Environment Variables** no painel
2. Adicione `NETDATA_USER` e `NETDATA_PASSWORD`
3. Clique em **Restart** ou **Redeploy**

### Containers não iniciam

**Verificar logs no Coolify:**
1. Vá na aba **Logs**
2. Selecione o container com problema
3. Leia os erros

**Logs via SSH:**
```bash
cd /data/coolify/applications/[seu-projeto-id]
docker-compose logs netdata
docker-compose logs nginx
```

### Dashboard não carrega após login

```bash
# Verificar se os containers estão na mesma rede
docker network ls
docker network inspect [nome-da-rede]

# Testar conectividade interna
docker exec [nginx-container-id] wget -O- http://netdata:19999
```

### Trocar a Senha

Super fácil!

1. No painel do Coolify, vá em **Environment Variables**
2. Altere o valor de `NETDATA_PASSWORD` (e/ou `NETDATA_USER`)
3. Clique em **Save**
4. Clique em **Restart**

**✅ Pronto!** A nova senha já está ativa.

## 🔒 Segurança no Coolify

### Recomendações:

1. **Use HTTPS com Domínio**
   - O Coolify gerencia SSL automaticamente
   - Muito mais seguro que HTTP

2. **Cloudflare Tunnel** (Avançado)
   - Se seu Coolify está atrás do CF Tunnel
   - Configure o domínio no Cloudflare
   - Adicione regras de acesso (IP whitelist, OAuth)

3. **Firewall**
   ```bash
   # Bloquear acesso direto à porta se usar domínio
   sudo ufw deny 19999/tcp
   
   # O tráfego vai passar pelo proxy do Coolify
   ```

4. **Monitorar Acessos**
   ```bash
   # Ver tentativas de login
   docker-compose logs nginx | grep "401\|403"
   ```

## 📊 Recursos do Coolify Integrados

O Coolify oferece recursos extras:

- ✅ **SSL automático** (Let's Encrypt)
- ✅ **Logs centralizados** no painel
- ✅ **Health checks** automáticos
- ✅ **Rollback** fácil para versões anteriores
- ✅ **Webhooks** para deploy automático no git push

## 🔄 Atualização Automática via Git

Para ativar deploy automático:

1. No Coolify, vá em **Settings** do recurso
2. Ative **Automatic Deployment**
3. Configure o **Webhook** no GitHub

Agora, todo `git push` vai fazer deploy automático! 🎉

## 📝 Estrutura no VPS

```
/data/coolify/
└── applications/
    └── [seu-projeto-id]/
        ├── docker-compose.yaml
        ├── netdata/
        │   └── netdata.conf
        ├── nginx/
        │   ├── nginx.conf
        │   └── .htpasswd  ← Criar este manualmente
        └── volumes/
            ├── netdata_lib/
            └── netdata_cache/
```

## 🎯 Checklist Final

- [ ] Variáveis `NETDATA_USER` e `NETDATA_PASSWORD` configuradas no Coolify
- [ ] Build Pack configurado como "Docker Compose"
- [ ] Deploy realizado com sucesso (logs verdes)
- [ ] 2 containers rodando (netdata + nginx)
- [ ] Tela de login aparecendo ao acessar
- [ ] Login funcionando com usuário/senha
- [ ] Dashboard do Netdata carregando completamente

## 💡 Dicas Extras

### Ver todos os containers do Netdata no Coolify

O Netdata vai mostrar **todos os containers do Coolify**! Muito útil para monitorar:
- CPU e memória de cada aplicação
- Rede de cada container
- Processos internos

### Alertas

Configure alertas do Netdata para Discord/Slack:
- Veja o [README.md](README.md) para mais detalhes

### Backup

Os dados históricos ficam em volumes Docker. Para backup:

```bash
# Backup
cd /data/coolify/applications/[seu-projeto-id]
docker run --rm -v netdata_lib:/data -v $(pwd):/backup alpine tar czf /backup/netdata-backup.tar.gz /data

# Restore
docker run --rm -v netdata_lib:/data -v $(pwd):/backup alpine tar xzf /backup/netdata-backup.tar.gz -C /
```

---

🎉 **Pronto!** Seu Netdata está rodando seguro no Coolify!

Se tiver problemas, consulte os logs no painel do Coolify ou execute `docker-compose logs` via SSH.

