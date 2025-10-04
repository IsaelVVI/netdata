# 🚀 Instalação Rápida - Netdata Protegido

## 📌 Para Coolify (Recomendado)

### Passo 1: Adicionar Variáveis de Ambiente

No painel do Coolify, em **Environment Variables**, adicione:

```
NETDATA_USER=admin
NETDATA_PASSWORD=SuaSenhaForte123!
```

### Passo 2: Deploy

1. Configure **Build Pack** como `Docker Compose`
2. Clique em **Deploy** 🚀
3. Aguarde (2-3 minutos)

### Passo 3: Acessar

- Com domínio: `https://netdata.seudominio.com`
- Sem domínio: `http://IP-DO-VPS:19999`

Digite o usuário e senha que você configurou!

---

## 💻 Para Uso Local (Docker Compose)

### Passo 1: Configurar Credenciais

```bash
# Copiar arquivo de exemplo
cp env.example .env

# Editar e definir suas credenciais
nano .env
```

Conteúdo do `.env`:
```bash
NETDATA_USER=admin
NETDATA_PASSWORD=MinhaSenh@Fort3
```

### Passo 2: Iniciar

```bash
docker-compose up -d
```

### Passo 3: Acessar

```
http://localhost:19999
```

---

## 🔧 Comandos Úteis

```bash
# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f

# Parar
docker-compose down

# Reiniciar
docker-compose restart

# Trocar senha (edite .env e depois):
docker-compose restart nginx
```

---

## 🆘 Problemas?

### Container nginx não inicia

```bash
# Verificar se as variáveis estão definidas
docker-compose config

# Ver logs detalhados
docker-compose logs nginx
```

### Senha não funciona

1. Verifique se `NETDATA_PASSWORD` está definida no `.env` ou Coolify
2. Reinicie: `docker-compose restart nginx`

---

Para mais detalhes:
- 📖 [README.md](README.md) - Guia completo
- 🚀 [COOLIFY-SETUP.md](COOLIFY-SETUP.md) - Guia específico Coolify

