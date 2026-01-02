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
   ├── sync. ps1          # Script principal
   ├── projetos.txt      # Lista de projetos Git
   └── logs\             # Logs por projeto
```

---

## 📄 Arquivo projetos.txt

Contém um caminho por linha, apontando para cada projeto Git no OneDrive:

```text
D:\OneDrive\PROJETOS-WEB\confortMoveis
D:\OneDrive\PROJETOS-WEB\outroProjeto
```

⚠️ **Cada pasta listada deve ser um repositório Git válido.**

---

## ⚙️ Script sync.ps1

**Responsabilidades do script:**

- Percorrer todos os projetos listados
- Executar `git pull`
- Registrar resultado em log
- Notificar erro no Windows
- Apagar logs antigos automaticamente

**Principais configurações no script:**

```powershell
$listaProjetos = "D:\OneDrive\scripts\projetos.txt"
$logDir = "D:\OneDrive\scripts\logs"
$diasParaManter = 7
```

---

## ▶️ Como testar manualmente (opcional)

Use apenas para teste inicial ou depuração.

### Opção 1 — Pelo PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File "D:\OneDrive\scripts\sync.ps1"
```

### Opção 2 — Pelo Agendador de Tarefas

1. Abra o **Agendador de Tarefas**
2. Clique com o botão direito na tarefa
3. Selecione **Executar**

---

## ⏰ Agendamento no Windows 11

O tempo de execução não fica no script, e sim no **Agendador de Tarefas**.

### Configuração recomendada:

#### 🔹 Geral
- **Nome:** `Git Pull - Projetos OneDrive`
- Marcar: **Executar com privilégios mais altos**

#### 🔹 Gatilhos
- **Tipo:** Em um agendamento
- **Configuração:** Diariamente
- **Repetir a cada:** 5 minutos
- **Por uma duração de:** Indefinidamente
- **Status:** Habilitado

#### 🔹 Ações
- **Programa:**
  ```text
  powershell.exe
  ```
- **Argumentos:**
  ```text
  -ExecutionPolicy Bypass -File "D:\OneDrive\scripts\sync.ps1"
  ```

---

## 📝 Logs

Cada projeto possui seu próprio arquivo de log:

```text
D:\OneDrive\scripts\logs\confortMoveis.log
```

**Exemplo de conteúdo:**

```text
[2026-01-02 07:45:01] Iniciando pull em confortMoveis
Already up to date. 
[2026-01-02 07:45:01] Pull finalizado com sucesso
```

---

## 🔔 Notificações de Erro

Se o `git pull` retornar erro (`error` ou `fatal`):

- Um popup do Windows será exibido
- O erro ficará registrado no log do projeto

---

## ♻️ Log Rotativo

Logs antigos são apagados automaticamente. 

**Configuração:**

```powershell
$diasParaManter = 7
```

Basta ajustar o número de dias conforme sua necessidade.

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