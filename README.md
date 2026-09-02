# Ren'Py SDK Mods & Console Tools

Uma extensão para a Ren'Py SDK/Launcher que adiciona opção de construir/compilar para consoles linux tipo R36s com cfw darkOS/ArkOS e afins. Além disso, adiciona uma opção para incluir um menu de ajuste in-game para personalizar tamanho e posição das fontes do diálogo e menu rápido, e adicionar o seletor de idiomas no menu de preferências do jogo (ainda requer fazer a tradução manualmente).

Desenvolvido por **Luana** ([@impfenix](https://github.com/impfenix)).

---

## 🛠️ O que tem neste repositório?

### 1. `renpy_mod_tools.sh` (O Patcher do SDK)
Este script é executado no seu **computador/PC**. Ele modifica os arquivos internos da engine do Ren'Py SDK para adicionar um novo painel de ferramentas diretamente na interface do Launcher. 

**Recursos adicionados ao SDK:**
* **Corrigir e Extrair Diálogos:** Antes de extrair traduções nativamente, a engine executa o `unrpa` corretamente e roda `find -name "*.rpyc" -type f -delete` no projeto, forçando a leitura limpa sem conflitos.
* **Injetar Menu de Ajustes de UI:** Adiciona o código flutuante de configuração diretamente nos arquivos do seu projeto com um clique.
* **Compilar para R36s (ArkOS/DaarkOS):** Otimiza a pasta do jogo deletando dependências de Windows, Mac e Linux 32-bit, além de aplicar permissão de execução (`chmod +x`) aos executáveis `.sh`.

**Como usar:**
Execute o arquivo pelo terminal do seu Linux (ou WSL):
```bash
chmod +x renpy_mod_tools.sh
./renpy_mod_tools.sh
```
