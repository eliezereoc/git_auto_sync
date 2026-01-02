# Script de diagnostico
$listaProjetos = "D:\OneDrive\git_auto_sync\projetos.txt"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTICO - Git Auto Sync" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ler projetos
if (Test-Path $listaProjetos) {
    $projetos = Get-Content $listaProjetos | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("#") }
    
    Write-Host "Total de projetos listados: $($projetos.Count)" -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($projeto in $projetos) {
        $projeto = $projeto.Trim()
        
        Write-Host "----------------------------------------" -ForegroundColor Gray
        Write-Host "Caminho: $projeto" -ForegroundColor White
        
        # Verificar se existe
        if (Test-Path $projeto) {
            Write-Host "[OK] Pasta existe" -ForegroundColor Green
            
            # Verificar . git
            $gitPath = Join-Path $projeto ".git"
            Write-Host "    Procurando:  $gitPath" -ForegroundColor Gray
            
            if (Test-Path $gitPath) {
                Write-Host "[OK] E repositorio Git valido" -ForegroundColor Green
                
                # Testar comando git
                Push-Location $projeto
                $branch = git branch --show-current 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Branch atual: $branch" -ForegroundColor Green
                } else {
                    Write-Host "[ERRO] Erro ao executar git: $branch" -ForegroundColor Red
                }
                
                $remote = git remote -v 2>&1 | Select-Object -First 1
                if ($remote) {
                    Write-Host "[OK] Remote:  $remote" -ForegroundColor Green
                } else {
                    Write-Host "[AVISO] Sem remote configurado" -ForegroundColor Yellow
                }
                
                Pop-Location
            } else {
                Write-Host "[ERRO] Pasta .git NAO encontrada" -ForegroundColor Red
                Write-Host "    Conteudo da pasta:" -ForegroundColor Gray
                Get-ChildItem $projeto -Force | Select-Object -First 10 | ForEach-Object {
                    Write-Host "    - $($_.Name)" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "[ERRO] Pasta NAO existe" -ForegroundColor Red
        }
        
        Write-Host ""
    }
} else {
    Write-Host "[ERRO] Arquivo projetos.txt nao encontrado!" -ForegroundColor Red
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Diagnostico concluido" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan