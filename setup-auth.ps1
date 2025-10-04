# Script PowerShell para configurar autenticação do Netdata
# Para Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   Configuração de Autenticação Netdata" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Criar diretório nginx se não existir
if (-not (Test-Path "nginx")) {
    New-Item -ItemType Directory -Path "nginx" | Out-Null
}

# Solicitar usuário
$username = Read-Host "Digite o nome de usuário"

# Solicitar senha de forma segura
$password = Read-Host "Digite a senha" -AsSecureString
$passwordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Gerar hash bcrypt (usando função simples)
# Nota: Para produção, considere usar htpasswd via Docker
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Este script usa criptografia básica." -ForegroundColor Yellow
Write-Host "Para maior segurança em produção, use o método via Docker abaixo." -ForegroundColor Yellow
Write-Host ""

# Usar Docker para gerar o hash se disponível
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Gerando hash de senha seguro com Docker..." -ForegroundColor Green
    $htpasswdContent = docker run --rm -i httpd:alpine htpasswd -nbB "$username" "$passwordText"
    
    if ($LASTEXITCODE -eq 0) {
        Set-Content -Path "nginx\.htpasswd" -Value $htpasswdContent
        Write-Host ""
        Write-Host "✅ Autenticação configurada com sucesso!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Próximos passos:" -ForegroundColor Cyan
        Write-Host "1. Execute: docker-compose up -d"
        Write-Host "2. Acesse: http://localhost:19999"
        Write-Host "3. Use o usuário '$username' e a senha que você definiu"
        Write-Host ""
    } else {
        Write-Host "❌ Erro ao gerar hash de senha" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ Docker não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, execute no VPS com Linux:" -ForegroundColor Yellow
    Write-Host "  bash setup-auth.sh" -ForegroundColor White
    Write-Host ""
    Write-Host "Ou use Docker Desktop no Windows para executar:" -ForegroundColor Yellow
    Write-Host "  docker run --rm -i httpd:alpine htpasswd -nbB $username senha > nginx\.htpasswd" -ForegroundColor White
    exit 1
}

