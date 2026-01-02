# Caminhos principais
$listaProjetos = "D:\OneDrive\git_auto_sync\projetos.txt" # Caminho da lista de projetos
$logDir = "D:\DEV\LOGS_PRJ_ONEDRIVE\logs"           # Caminho onde ficam os logs
$diasParaManter = 30                                # Quantidade de dias de logs a manter

# Criar diretório de logs se não existir
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# Função para escrever log
function Write-Log {
    param(
        [string]$projeto,
        [string]$mensagem
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH: mm:ss"
    $logFile = Join-Path $logDir "$projeto.log"
    $logLine = "[$timestamp] $mensagem"
    
    Add-Content -Path $logFile -Value $logLine
}

# Função para exibir notificação de erro
function Show-ErrorNotification {
    param(
        [string]$projeto,
        [string]$erro
    )
    
    Add-Type -AssemblyName System.Windows.Forms
    $notification = New-Object System.Windows.Forms.NotifyIcon
    $notification.Icon = [System.Drawing.SystemIcons]::Error
    $notification.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $notification.BalloonTipTitle = "Git Pull - Erro"
    $notification.BalloonTipText = "Erro no projeto: $projeto`n$erro"
    $notification.Visible = $true
    $notification.ShowBalloonTip(10000)
    
    Start-Sleep -Seconds 2
    $notification.Dispose()
}

# Função para limpar logs antigos
function Clear-OldLogs {
    $dataLimite = (Get-Date).AddDays(-$diasParaManter)
    
    Get-ChildItem -Path $logDir -Filter "*.log" | ForEach-Object {
        if ($_.LastWriteTime -lt $dataLimite) {
            Remove-Item $_.FullName -Force
            Write-Host "Log antigo removido: $($_.Name)" -ForegroundColor Yellow
        }
    }
}

# Verificar se arquivo de projetos existe
if (-not (Test-Path $listaProjetos)) {
    Write-Host "ERRO:  Arquivo $listaProjetos não encontrado!" -ForegroundColor Red
    exit 1
}

# Ler lista de projetos
$projetos = Get-Content $listaProjetos | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("#") }

if ($projetos.Count -eq 0) {
    Write-Host "AVISO: Nenhum projeto configurado em $listaProjetos" -ForegroundColor Yellow
    exit 0
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Git Auto Sync - Iniciando..." -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "Total de projetos: $($projetos.Count)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Processar cada projeto
foreach ($projetoPath in $projetos) {
    $projetoPath = $projetoPath.Trim()
    
    # Verificar se caminho existe
    if (-not (Test-Path $projetoPath)) {
        Write-Host "`n[ERRO] Caminho não encontrado: $projetoPath" -ForegroundColor Red
        continue
    }
    
    # Obter nome do projeto
    $projetoNome = Split-Path $projetoPath -Leaf
    
    Write-Host "`n----------------------------------------" -ForegroundColor Gray
    Write-Host "Projeto: $projetoNome" -ForegroundColor White
    Write-Host "Caminho: $projetoPath" -ForegroundColor Gray
    
    # Verificar se é repositório Git
    $gitPath = Join-Path $projetoPath ".git"
    if (-not (Test-Path $gitPath)) {
        Write-Host "[AVISO] Não é um repositório Git válido" -ForegroundColor Yellow
        Write-Log -projeto $projetoNome -mensagem "AVISO: Não é um repositório Git válido"
        continue
    }
    
    # Registrar início
    Write-Log -projeto $projetoNome -mensagem "Iniciando pull em $projetoNome"
    
    # Executar git pull
    try {
        Push-Location $projetoPath
        
        # Verificar se há conexão com remote
        $remoteCheck = git remote -v 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Sem remote configurado"
        }
        
        # Executar pull e capturar saída
        $ErrorActionPreference = 'Continue'
        $output = & git pull 2>&1
        $gitExitCode = $LASTEXITCODE
        $outputString = $output | Out-String
        
        # Verificar se houve erro REAL (não apenas mensagens no stderr)
        $temErroReal = $gitExitCode -ne 0 -and ($outputString -match "fatal:|error:|Authentication failed|Permission denied")
        
        if ($temErroReal) {
            throw $outputString
        }
        
        # Sucesso
        Write-Host "[OK] Pull executado com sucesso" -ForegroundColor Green
        if ($outputString -match "Already up to date") {
            Write-Host "     Já está atualizado" -ForegroundColor Gray
        } elseif ($outputString -match "Fast-forward|Updating") {
            Write-Host "     Arquivos atualizados!" -ForegroundColor Cyan
        }
        
        Write-Log -projeto $projetoNome -mensagem $outputString.Trim()
        Write-Log -projeto $projetoNome -mensagem "Pull finalizado com sucesso"
        
    } catch {
        $erroMsg = $_.Exception.Message
        Write-Host "[ERRO] $erroMsg" -ForegroundColor Red
        Write-Log -projeto $projetoNome -mensagem "ERRO: $erroMsg"
        Show-ErrorNotification -projeto $projetoNome -erro $erroMsg
        
    } finally {
        Pop-Location
        $ErrorActionPreference = 'Stop'
    }
}

# Limpar logs antigos
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Limpando logs antigos (> $diasParaManter dias)..." -ForegroundColor Cyan
Clear-OldLogs

Write-Host "`n[CONCLUÍDO] Sincronização finalizada!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan