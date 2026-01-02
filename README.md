# 🔄 Git Auto Sync com OneDrive (Windows 11)

Este projeto automatiza a atualização (`git pull`) de **vários repositórios Git** armazenados no OneDrive, usando **PowerShell + Agendador de Tarefas do Windows**. 

A solução:
- Atualiza os projetos automaticamente a cada X minutos
- Gera logs por projeto
- Remove logs antigos automaticamente (log rotativo)
- Exibe notificação no Windows em caso de erro

---

## 📁 Estrutura de Pastas

```text
D:\OneDrive\scripts\
   ├── sync.ps1              # Script principal que executa o git pull
   ├── projetos.txt          # Lista de caminhos dos repositórios Git
   ├── projetos.txt.example  # Arquivo de exemplo (opcional)
   └── logs\                 # Pasta criada automaticamente pelo script
       ├── projeto1.log      # Log individual de cada repositório
       ├── projeto2.log
       └── ...
```

**Observações importantes:**
- A pasta `logs\` será criada automaticamente na primeira execução
- Cada repositório terá seu próprio arquivo `.log` com o nome da pasta do projeto
- Os caminhos podem ser ajustados conforme sua estrutura do OneDrive

---

## 📄 Arquivo projetos.txt

Contém um caminho por linha, apontando para cada projeto Git no OneDrive.

**Formato do arquivo:**

```text
D:\OneDrive\PROJETOS-WEB\outroProjeto
D:\OneDrive\PROJETOS-PYTHON\meuApp
```

**Regras importantes:**
- ✅ Um caminho completo por linha
- ✅ Sem aspas, vírgulas ou caracteres especiais
- ✅ Linhas em branco são ignoradas
- ✅ Comentários não são suportados
- ⚠️ **Cada pasta deve ser um repositório Git válido** (deve conter a pasta `.git`)
- ⚠️ O repositório precisa ter um `remote` configurado (origem)

**Como verificar se um repositório é válido:**

```powershell
cd "D:\OneDrive\PROJETOS-WEB\mauPrjeto"
git status  # Deve mostrar o status sem erros
git remote -v  # Deve mostrar a URL do repositório remoto
```

---

## ⚙️ Script sync.ps1

**Responsabilidades do script:**

1. **Leitura:** Carrega a lista de projetos do arquivo `projetos.txt`
2. **Validação:** Verifica se cada pasta existe e contém um repositório Git
3. **Sincronização:** Executa `git pull` em cada projeto
4. **Logging:** Registra data/hora, comandos executados e resultados
5. **Notificação:** Exibe popup do Windows em caso de erro
6. **Limpeza:** Remove logs com mais de X dias automaticamente

**Principais configurações no script:**

```powershell
# Caminho do arquivo com lista de repositórios
$listaProjetos = "D:\OneDrive\scripts\projetos.txt"

# Pasta onde os logs serão salvos
$logDir = "D:\OneDrive\scripts\logs"

# Quantos dias manter os arquivos de log (após isso são apagados)
$diasParaManter = 7
```

**Fluxo de execução:**

```text
Início
  ↓
Lê projetos.txt
  ↓
Para cada projeto:
  ↓
  Verifica se existe
  ↓
  Entra na pasta (cd)
  ↓
  Executa: git pull
  ↓
  Salva resultado no log
  ↓
  Se houver erro → Notifica
  ↓
Limpa logs antigos
  ↓
Fim
```

**O que o script NÃO faz:**
- ❌ Não faz `git push` (apenas `pull`)
- ❌ Não resolve conflitos automaticamente
- ❌ Não faz commit de alterações locais
- ❌ Não cria branches ou tags

---

## ▶️ Como testar manualmente (opcional)

Use apenas para teste inicial ou depuração.

### Opção 1 — Pelo PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File "D:\OneDrive\scripts\sync.ps1"
```

### Opção 2 — Pelo Agendador de Tarefas

**Pré-requisito:** A tarefa já deve estar criada no Agendador de Tarefas (veja seção "Agendamento no Windows 11").

**Passo a passo detalhado:**

1. **Abrir o Agendador de Tarefas:**
   - Pressione `Win + R`
   - Digite: `taskschd.msc`
   - Pressione `Enter`

2. **Localizar a tarefa:**
   - No painel esquerdo, clique em **Biblioteca do Agendador de Tarefas**
   - Procure pela tarefa chamada `Git Pull - Projetos OneDrive`
   - Se não encontrar na raiz, verifique subpastas

3. **Executar manualmente:**
   - Clique com o **botão direito** sobre a tarefa
   - Selecione **Executar**
   - Uma janela do PowerShell pode aparecer brevemente

4. **Verificar o resultado:**
   - Na coluna **Última Execução**, veja a data/hora
   - Na coluna **Resultado da Última Execução**, deve aparecer `(0x0)` se deu certo
   - Se aparecer outro código, consulte os logs para mais detalhes

5. **Acompanhar em tempo real (opcional):**
   - Clique na tarefa uma vez (não duplo clique)
   - No painel inferior, clique na aba **Histórico**
   - Veja todos os eventos de execução

**Atalho rápido:**
```powershell
# Executar a tarefa pela linha de comando:
schtasks /Run /TN "Git Pull - Projetos OneDrive"
```

---

## ⏰ Agendamento no Windows 11

O tempo de execução não fica no script, e sim no **Agendador de Tarefas**.

### 📋 Passo a passo completo para criar a tarefa:

#### **1️⃣ Abrir o Agendador de Tarefas**

- Pressione `Win + R`, digite `taskschd.msc` e pressione Enter
- Ou busque "Agendador de Tarefas" no Menu Iniciar

#### **2️⃣ Criar nova tarefa**

- No painel direito, clique em **Criar Tarefa...** (não "Criar Tarefa Básica")
- Uma janela com abas será aberta

#### **3️⃣ Aba GERAL**

- **Nome:** `Git Pull - Projetos OneDrive`
- **Descrição (opcional):** `Sincroniza automaticamente repositórios Git do OneDrive`
- **Opções de segurança:**
  - ✅ Marque: **Executar com privilégios mais altos**
  - Selecione: **Executar estando o usuário conectado ou não** (se quiser rodar em segundo plano)
  - ✅ Marque: **Oculto** (opcional, para não mostrar janela)
- **Configurar para:** `Windows 10` ou `Windows 11`

#### **4️⃣ Aba GATILHOS/DISPARADOR**

- Clique em **Novo...**
- Configure:
  - **Iniciar a tarefa:** `Em um agendamento`
  - **Configurações:**
    - Selecione: `Diariamente`
    - **Iniciar em:** Escolha uma data (ex: hoje)
    - **Iniciar às:** `00:00:00` (ou qualquer horário)
    - ✅ Marque: **Repetir a tarefa a cada:** `5 minutos`
    - **Por uma duração de:** `Indefinidamente`
  - **Configurações avançadas:**
    - ✅ Marque: **Habilitado**
    - ⚠️ **NÃO marque** "Parar a tarefa se executar por mais de..." (ou deixe em 3 dias)
  - Clique em **OK**

**💡 Explicação do gatilho:**
- A tarefa inicia às 00:00 e repete a cada 5 minutos
- Isso significa que executará: 00:00, 00:05, 00:10, 00:15, etc.
- Ajuste o intervalo conforme sua necessidade (5, 10, 15, 30 minutos, etc.)

#### **5️⃣ Aba AÇÕES**

- Clique em **Novo...**
- Configure:
  - **Ação:** `Iniciar um programa`
  - **Programa/script:**
    ```text
    powershell.exe
    ```
  - **Adicionar argumentos (opcional):**
    ```text
    -ExecutionPolicy Bypass -File "D:\OneDrive\scripts\sync.ps1"
    ```
    ⚠️ **Importante:** Ajuste o caminho para onde seu script está localizado
  - **Iniciar em (opcional):** Deixe em branco
  - Clique em **OK**

#### **6️⃣ Aba CONDIÇÕES**

**Energia:**
- ❌ Desmarque: **Iniciar a tarefa apenas se o computador estiver conectado à energia CA**
- ❌ Desmarque: **Parar se o computador alternar para bateria**

**Rede (opcional):**
- ✅ Marque: **Iniciar somente se a seguinte conexão de rede estiver disponível:** `Qualquer conexão`

**Ocioso:**
- ❌ Desmarque todas as opções relacionadas a "ocioso"

#### **7️⃣ Aba CONFIGURAÇÕES**

- ✅ Marque: **Permitir que a tarefa seja executada sob demanda**
- ✅ Marque: **Executar tarefa o mais breve possível após perda de execução agendada**
- ❌ Desmarque: **Se a tarefa falhar, reiniciar a cada:** (deixe o agendamento normal cuidar disso)
- **Se a tarefa já estiver em execução, a seguinte regra será aplicada:**
  - Selecione: `Não iniciar uma nova instância` (evita múltiplas execuções simultâneas)
- Clique em **OK**

#### **8️⃣ Finalizar**

- Pode ser solicitada sua senha do Windows
- A tarefa aparecerá na lista do Agendador de Tarefas
- Status deve estar: **Pronto**

---

### ✅ Verificando se está funcionando:

1. Clique com botão direito na tarefa → **Executar**
2. Aguarde alguns segundos
3. Vá em `D:\OneDrive\scripts\logs\` e confira se os arquivos `.log` foram criados/atualizados
4. Veja a data/hora da **Última Execução** e **Próxima Execução** na tarefa

### 🔧 Configurações alternativas de intervalo:

| Necessidade | Configuração |
|-------------|-------------|
| A cada 5 minutos | Repetir a cada: `5 minutos` |
| A cada 15 minutos | Repetir a cada: `15 minutos` |
| A cada hora | Repetir a cada: `1 hora` |
| A cada 30 minutos | Repetir a cada: `30 minutos` |
| Apenas ao ligar o PC | Gatilho: `Ao fazer logon` (remover repetição) |
| A cada 2 horas | Repetir a cada: `2 horas` |

---

## 📝 Logs

Cada projeto possui seu próprio arquivo de log com nome baseado na pasta do repositório.

**Estrutura dos logs:**

```text
D:\OneDrive\scripts\logs\
   ├── confortMoveis.log     # Logs do projeto confortMoveis
   ├── outroProjeto.log      # Logs do projeto outroProjeto
   └── meuApp.log            # Logs do projeto meuApp
```

**Formato do nome do log:**
- O nome é extraído da última pasta do caminho
- Exemplo: `D:\OneDrive\PROJETOS\meuApp` → gera `meuApp.log`

### 📄 Exemplos de conteúdo:

**✅ Cenário 1: Atualização bem-sucedida (sem mudanças)**

```text
[2026-01-02 07:45:01] Iniciando pull em confortMoveis
Already up to date.
[2026-01-02 07:45:01] Pull finalizado com sucesso
```

**✅ Cenário 2: Atualização com novos commits**

```text
[2026-01-02 08:30:15] Iniciando pull em outroProjeto
Updating 3a4b5c6..7d8e9f0
Fast-forward
 src/index.js | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)
[2026-01-02 08:30:16] Pull finalizado com sucesso
```

**❌ Cenário 3: Erro de conexão**

```text
[2026-01-02 09:15:30] Iniciando pull em meuApp
fatal: unable to access 'https://github.com/user/repo.git/': Could not resolve host: github.com
[2026-01-02 09:15:35] ERRO detectado no pull
```

**❌ Cenário 4: Conflito de merge**

```text
[2026-01-02 10:00:00] Iniciando pull em confortMoveis
error: Your local changes to the following files would be overwritten by merge:
	src/config.js
Please commit your changes or stash them before you merge.
Aborting
[2026-01-02 10:00:01] ERRO detectado no pull
```

### 🔍 Como interpretar os logs:

| Mensagem no Log | Significado | Ação necessária |
|-----------------|-------------|------------------|
| `Already up to date` | Sem alterações no remoto | ✅ Nenhuma |
| `Fast-forward` | Atualizou com sucesso | ✅ Nenhuma |
| `fatal: unable to access` | Sem conexão/internet | ⚠️ Verificar rede |
| `error: Your local changes` | Arquivos modificados localmente | ⚠️ Fazer commit ou stash |
| `CONFLICT` | Conflito de merge | ❌ Resolver manualmente |
| `fatal: not a git repository` | Pasta sem Git | ❌ Inicializar repo ou corrigir caminho |

### 📊 Localização e visualização:

**Abrir pasta de logs rapidamente:**
```powershell
explorer "D:\OneDrive\scripts\logs"
```

**Ver últimas linhas de um log:**
```powershell
Get-Content "D:\OneDrive\scripts\logs\confortMoveis.log" -Tail 20
```

**Ver todos os erros:**
```powershell
Get-ChildItem "D:\OneDrive\scripts\logs\*.log" | Select-String "ERRO"
```

---

## 🔔 Notificações de Erro

O script monitora a saída do `git pull` e detecta automaticamente erros.

### ⚠️ Quando a notificação aparece:

**Palavras-chave detectadas na saída do Git:**
- `error:`
- `fatal:`
- `CONFLICT`
- `Aborting`

Se qualquer uma dessas palavras aparecer, o script:
1. ✉️ Exibe uma notificação popup do Windows
2. 📝 Registra a mensagem de erro no log
3. ⏭️ Continua para o próximo projeto (não para a execução)

### 📢 Como funciona a notificação:

**Informações exibidas no popup:**
- **Título:** "Erro no Git Pull"
- **Mensagem:** Nome do projeto com problema
- **Ícone:** ⚠️ Aviso ou ❌ Erro

**Exemplo de notificação:**
```
╔══════════════════════════════╗
║  ⚠️ Erro no Git Pull         ║
╠══════════════════════════════╣
║  Projeto: confortMoveis      ║
║  Verifique o log para        ║
║  mais detalhes.              ║
╚══════════════════════════════╝
```

### 🔕 Se não quiser notificações:

Comente ou remova a linha no script que contém:
```powershell
# [System.Windows.Forms.MessageBox]::Show(...)
```

### 📱 Notificações silenciosas (toast):

Para notificações estilo Windows 11 (menos intrusivas), você pode:
1. Instalar módulo: `Install-Module -Name BurntToast`
2. Substituir no script o `MessageBox` por:
```powershell
New-BurntToastNotification -Text "Erro no Git Pull", "Projeto: $nomeProjeto"
```

---

## ♻️ Log Rotativo

Logs antigos são apagados automaticamente para evitar acúmulo de arquivos.

### ⚙️ Como funciona:

**Configuração no script:**

```powershell
$diasParaManter = 7  # Mantenha logs dos últimos 7 dias
```

**Comportamento:**
- A cada execução, o script verifica a data de modificação de cada arquivo `.log`
- Se o arquivo tiver mais de `$diasParaManter` dias, é deletado
- Apenas arquivos dentro da pasta `logs\` são afetados

### 📅 Exemplos de configuração:

| Dias | Uso recomendado |
|------|------------------|
| `3` | Testes ou desenvolvimento |
| `7` | Uso pessoal (padrão) |
| `14` | Pequenas equipes |
| `30` | Auditoria ou empresas |
| `90` | Requisitos de compliance |

### 🔢 Cálculo de espaço em disco:

**Estimativa:**
- Cada execução gera ~1-2 KB por projeto
- Com 10 projetos, executando a cada 5 min:
  - 288 execuções/dia × 10 projetos = 2.880 execuções
  - ~3-6 MB/dia
  - Com 7 dias: ~20-40 MB

### 💾 Alternativas ao log rotativo:

**1. Compactar em vez de deletar:**
```powershell
# Compactar logs com mais de 7 dias
Compress-Archive -Path "$logDir\*.log" -DestinationPath "$logDir\logs-$(Get-Date -Format 'yyyy-MM').zip"
```

**2. Mover para arquivo morto:**
```powershell
# Mover logs antigos para subpasta
$arquivoDir = "$logDir\arquivo"
Move-Item -Path "$logDir\*.log" -Destination $arquivoDir
```

**3. Desabilitar rotação:**
```powershell
# Comentar a seção de limpeza no script
# ou definir um valor muito alto:
$diasParaManter = 3650  # ~10 anos
```

### 🧹 Limpeza manual:

**Deletar todos os logs:**
```powershell
Remove-Item "D:\OneDrive\scripts\logs\*.log" -Force
```

**Deletar logs de um projeto específico:**
```powershell
Remove-Item "D:\OneDrive\scripts\logs\confortMoveis.log" -Force
```

**Ver tamanho total dos logs:**
```powershell
$tamanho = (Get-ChildItem "D:\OneDrive\scripts\logs\*.log" | Measure-Object -Property Length -Sum).Sum
"$([math]::Round($tamanho/1MB, 2)) MB"
```

---

## 🔧 Manutenção e Melhorias

### Para adicionar um novo projeto: 
1. Edite `projetos.txt`
2. Adicione o caminho do repositório
3. Salve — não precisa reiniciar nada

### Para mudar o intervalo: 
- Ajuste o **Gatilho** no Agendador de Tarefas

### Para melhorias futuras:
- Separar logs por data
- Compactar logs antigos (.zip)
- Enviar alerta por e-mail
- Notificação estilo toast (Windows 11)
- Executar apenas se houver internet
- Relatório diário consolidado

---

## ✅ Boas Práticas

- Use Git remoto (GitHub/GitLab) como **fonte principal**
- Use OneDrive apenas como **espelho/backup**
- Evite `node_modules`, `dist`, `vendor` dentro do OneDrive
- Nunca use loops infinitos no script quando usar o Agendador

---

## 📌 Observação Final

**Após configurar o Agendador de Tarefas, não é necessário executar o script manualmente.**  
O Windows cuidará de tudo automaticamente. 

🚀
