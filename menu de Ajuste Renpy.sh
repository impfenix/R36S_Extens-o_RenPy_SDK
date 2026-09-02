#!/bin/bash
# ################################################################################
# # menu de Ajuste Renpy.sh                                                      #
# # By: Luana                                                                    #
# # GitHub: https://github.com/impfenix                                          #
# # Descricao: Lista jogos Ren'Py no console (ArkOS/DaarkOS), extrai RPA,        #
# # injeta o menu de ajuste de UI, limpa cache compilado (.rpyc) e roda o game.  #
# # Versao: 0.1 Alpha                                                            #
# # Data: 02/09/2026                                                             #
# # Destino: /roms/tools/ ou pasta de scripts do console                         #
# # Como Compilar: Não requer compilação. Dê permissão de execução com chmod +x  #
# ################################################################################

# Garante que o dialog funcione corretamente no ambiente de terminal do console
export TERM=linux

# Busca por pastas 'game' nos diretórios padrão do ArkOS/DaarkOS para identificar os jogos
OPTIONS=()
while IFS= read -r -d '' game_dir; do
    parent_dir=$(dirname "$game_dir")
    game_name=$(basename "$parent_dir")
    OPTIONS+=("$parent_dir" "$game_name")
done < <(find /roms /roms2 /media -type d -name "game" -print0 2>/dev/null)

# Verifica se encontrou algum jogo
if [ ${#OPTIONS[@]} -eq 0 ]; then
    dialog --msgbox "Nenhum jogo Ren'Py encontrado nas pastas padrão." 10 50
    clear
    exit 1
fi

# Cria o menu de seleção usando dialog (O ArkOS mapeia Botão A = Enter, Botão B = Esc)
CHOICE=$(dialog --clear --title "Injetar Menu de Ajustes Ren'Py" \
        --menu "Use as setas/analógico para mover.\nA (Confirmar) para selecionar.\nB (Voltar) para sair.\n\nSelecione o jogo:" \
        20 70 10 \
        "${OPTIONS[@]}" \
        2>&1 >/dev/tty)

# Se o usuário apertar B (Esc/Cancelar)
if [ -z "$CHOICE" ]; then
    clear
    exit 0
fi

# Define os diretórios baseados na escolha do usuário
GAME_DIR="$CHOICE"
GAME_FOLDER="$GAME_DIR/game"

clear
echo "========================================"
echo "Iniciando processo para: $(basename "$GAME_DIR")"
echo "========================================"

# Navega para a pasta do jogo
cd "$GAME_FOLDER" || exit 1

# Extrai o arquivo archive.rpa
if [ -f "archive.rpa" ]; then
    echo "[1/4] Extraindo archive.rpa..."
    unrpa -p ./ archive.rpa
else
    echo "[1/4] archive.rpa não encontrado na pasta principal. Pulando extração..."
fi

# Injeta o código do Menu de Ajuste
echo "[2/4] Injetando o ui_tweak.rpy..."
cat << 'EOF_RENPY' > "$GAME_FOLDER/ui_tweak.rpy"
init offset = 999

default persistent.tweak_quick_y = 0.50
default persistent.tweak_diag_y = 80
default persistent.tweak_name_y = -40
default persistent.tweak_diag_size = 30
default persistent.tweak_quick_size = 26
default persistent.tweak_show = True

screen ui_tweak():
    zorder 9999
    if persistent.tweak_show:
        drag:
            xpos 10 ypos 10
            frame:
                background "#000000F2"
                padding (20, 20)
                vbox:
                    spacing 10
                    text "Ajuste de UI" size 24 color "#FFF" bold True
                    
                    text "Menu Rápido (Y): [persistent.tweak_quick_y]" size 18 color "#FFF"
                    hbox:
                        spacing 20
                        textbutton " - " action SetField(persistent, "tweak_quick_y", persistent.tweak_quick_y - 0.01) text_color "#FFF"
                        textbutton " + " action SetField(persistent, "tweak_quick_y", persistent.tweak_quick_y + 0.01) text_color "#FFF"
                    
                    text "Texto Diálogo (Y): [persistent.tweak_diag_y]" size 18 color "#FFF"
                    hbox:
                        spacing 20
                        textbutton " - " action SetField(persistent, "tweak_diag_y", persistent.tweak_diag_y - 2) text_color "#FFF"
                        textbutton " + " action SetField(persistent, "tweak_diag_y", persistent.tweak_diag_y + 2) text_color "#FFF"
                    
                    text "Nome Personagem (Y): [persistent.tweak_name_y]" size 18 color "#FFF"
                    hbox:
                        spacing 20
                        textbutton " - " action SetField(persistent, "tweak_name_y", persistent.tweak_name_y - 2) text_color "#FFF"
                        textbutton " + " action SetField(persistent, "tweak_name_y", persistent.tweak_name_y + 2) text_color "#FFF"

                    text "Tamanho Fonte (Diálogo): [persistent.tweak_diag_size]" size 18 color "#FFF"
                    hbox:
                        spacing 20
                        textbutton " - " action SetField(persistent, "tweak_diag_size", persistent.tweak_diag_size - 1) text_color "#FFF"
                        textbutton " + " action SetField(persistent, "tweak_diag_size", persistent.tweak_diag_size + 1) text_color "#FFF"

                    text "Tamanho Fonte (Menu Rápido): [persistent.tweak_quick_size]" size 18 color "#FFF"
                    hbox:
                        spacing 20
                        textbutton " - " action SetField(persistent, "tweak_quick_size", persistent.tweak_quick_size - 1) text_color "#FFF"
                        textbutton " + " action SetField(persistent, "tweak_quick_size", persistent.tweak_quick_size + 1) text_color "#FFF"

                    null height 10
                    textbutton "Salvar e Fechar Menu" action [Function(renpy.save_persistent), SetField(persistent, "tweak_show", False)] text_color "#55FF55"

init python:
    config.overlay_screens.append("ui_tweak")
EOF_RENPY

# Apaga os arquivos compilados para forçar o Ren'Py a ler as novas modificações
echo "[3/4] Apagando cache compilado (*.rpyc)..."
find "$GAME_FOLDER" -name "*.rpyc" -type f -delete

# Encontra e executa o lançador principal do jogo
echo "[4/4] Iniciando o jogo..."
LAUNCHER=$(find "$GAME_DIR" -maxdepth 1 -name "*.sh" | head -n 1)

if [ -n "$LAUNCHER" ]; then
    echo "Executando: $(basename "$LAUNCHER")"
    cd "$GAME_DIR"
    bash "$LAUNCHER"
else
    echo "Nenhum arquivo .sh encontrado na raiz do jogo. O jogo não pôde ser iniciado automaticamente."
    sleep 4
fi