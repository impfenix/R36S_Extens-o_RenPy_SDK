# Ren'Py SDK Mods & Console Tools

Uma extensão para a Ren'Py SDK/Launcher que adiciona opções avançadas para desenvolvedores e modders. Este pacote permite otimizar e compilar jogos para consoles portáteis Linux (como R36s com ArkOS/DaarkOS), além de injetar menus de ajuste de interface (UI) em tempo real e corrigir o fluxo de extração de diálogos.

Desenvolvido por **([@impfenix](https://github.com/impfenix)).**

---

## 🛠️ Ferramentas Inclusas

### 1. Ren'Py SDK Mod Patcher (PC - Windows e Linux)
Scripts (`renpy_mod_tools.sh` e `renpy_mod_tools.bat`) executados no seu computador para modificar o Ren'Py SDK. Eles injetam novas funcionalidades de forma nativa e invisível diretamente na seção **Ações** da página inicial do Launcher.

**Recursos adicionados ao SDK:**
* **Extrair Diálogos (unrpa + del .rpyc):** Corrige a extração padrão da engine. Executa o `unrpa` silenciosamente na pasta do jogo e deleta os arquivos `.rpyc` para evitar conflitos de cache, forçando a leitura limpa dos scripts `.rpy` modificados.
* **Injetar Menu de Ajustes de UI:** Adiciona um painel flutuante arrastável dentro do jogo selecionado. Permite ajustar em tempo real (com botões `+` e `-`) o tamanho e a posição vertical (eixo Y) da caixa de nome, do texto de diálogo e do menu rápido. Excelente para consertar layouts que quebram após a troca de fontes em traduções.
* **Compilar para R36s (ArkOS/DaarkOS):** Prepara a pasta do jogo para rodar nativamente em portáteis baseados em ARM. Remove bibliotecas pesadas e redundantes (Windows, Mac, Linux 32-bit), deleta executáveis desnecessários e aplica permissões de execução (`chmod +x`) aos `.sh` principais.

### 2. Menu de Ajuste Renpy (Console Portátil)
Um script (`menu de Ajuste Renpy.sh`) desenhado para rodar diretamente no seu console portátil. 

**O que ele faz:**
Através de uma interface amigável baseada em `dialog`, ele varre os cartões SD (`/roms`) buscando jogos Ren'Py instalados e permite aplicar correções diretamente pelo console:
* Descompacta arquivos `.rpa`.
* Injeta o Menu de Ajuste de UI para você consertar o layout da tela diretamente pelo aparelho.
* Apaga o cache de compilação (`.rpyc`) local e inicializa o jogo logo em seguida.

---

## 🚀 Como Usar

### Modificando o Ren'Py SDK (No Computador)
1. Baixe o script correspondente ao seu sistema operacional:
   * **Linux:** `renpy_mod_tools.sh`
   * **Windows:** `renpy_mod_tools.bat`
2. **Linux:** Dê permissão de execução e rode no terminal:
   ```bash
   chmod +x renpy_mod_tools.sh
   ./renpy_mod_tools.sh
