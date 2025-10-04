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

### 2.3. Configurar Porta e Domínio

**Importante:** O serviço escuta na porta **19999** do host.

⚠️ **No Coolify, configure a porta corretamente:**
- Na seção **Ports**, certifique-se de que está mapeado `19999:80`
- Isso significa: porta 19999 externa → porta 80 interna do container

Você tem duas opções de acesso:

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
2. Certifique-se de que a porta está configurada como `19999`
3. Abra a porta no firewall (se necessário):
   ```bash
   sudo ufw allow 19999/tcp
   ```
4. Acesse via: `http://IP-DO-VPS:19999`

**⚠️ IMPORTANTE:** Acesse na porta **19999**, NÃO na porta 80!

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

### Verificar Logs (IMPORTANTE!)

Antes de acessar, verifique os logs do nginx:

```bash
# Ver logs do container nginx
docker logs [nginx-container-id]
```

Você deve ver:
```
🔧 Configurando Netdata com autenticação...
📦 Instalando apache2-utils...
🔐 Gerando arquivo de autenticação...
📝 Gerando configuração do Nginx...
✅ Autenticação configurada para o usuário: admin
🚀 Nginx configurado e pronto para iniciar!
```

Se NÃO ver essas mensagens, o script não rodou!

### Acessar o Dashboard

**Com Domínio:**
```
https://netdata.seudominio.com
```

**Sem Domínio:**
```
http://IP-DO-VPS:19999
```

**⚠️ Use a porta 19999, não 80!**

### Como Saber se a Autenticação Está Funcionando

✅ **Funcionando:** Aparece uma janela popup pedindo:
   - Usuário
   - Senha

❌ **NÃO funcionando:** Dashboard abre direto sem pedir senha

Se abrir sem senha:
1. Verifique os logs do nginx
2. Verifique se as variáveis `NETDATA_USER` e `NETDATA_PASSWORD` estão definidas
3. Reinicie o container: `docker restart [nginx-container]`

## 🔧 Troubleshooting no Coolify

### ⚠️ Problema: Acessando SEM SENHA

**Sintoma:** O dashboard abre direto sem pedir usuário/senha

**Causas possíveis:**
1. Variáveis de ambiente não configuradas
2. Script de setup não rodou
3. Configuração do nginx não foi gerada

**Solução passo a passo:**

```bash
# 1. Verificar se as variáveis estão definidas
docker exec [nginx-container-id] env | grep NETDATA

# Deve mostrar:
# NETDATA_USER=admin
# NETDATA_PASSWORD=sua-senha

# 2. Verificar logs do nginx
docker logs [nginx-container-id]

# Deve mostrar as mensagens de "Configurando..." e "✅ Autenticação configurada"

# 3. Verificar se .htpasswd foi criado
docker exec [nginx-container-id] cat /etc/nginx/.htpasswd

# Deve mostrar: admin:$2y$...hash...

# 4. Verificar configuração do nginx
docker exec [nginx-container-id] cat /etc/nginx/nginx.conf | grep auth_basic

# Deve mostrar:
#   auth_basic "Área Restrita - Netdata";
#   auth_basic_user_file /etc/nginx/.htpasswd;
```

Se algum desses não funcionar:
1. Adicione/verifique as variáveis no Coolify
2. Faça **Restart** do serviço
3. Verifique os logs novamente

### ⚠️ Problema: Acessando na PORTA 80 em vez de 19999

**Sintoma:** URL está como `http://ip:80` ou só `http://ip`

**Solução:**
- Acesse na porta correta: `http://IP-DO-VPS:19999`
- No Coolify, verifique se a porta está mapeada como `19999:80`

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
        │   └── entrypoint.sh  ← Gera configurações automaticamente
        └── volumes/
            ├── netdata_lib/
            └── netdata_cache/
```

**Nota:** Os arquivos `nginx.conf` e `.htpasswd` são gerados automaticamente pelo entrypoint durante a inicialização do container!

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

