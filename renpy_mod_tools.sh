#!/bin/bash
# ################################################################################
# # renpy_mod_tools.sh                                                           #
# # By: Luana                                                                    #
# # GitHub: https://github.com/impfenix/                                         #
# # Descricao: Patcher para modificar o Ren'Py SDK. Injeta as funções extras     #
# #            diretamente na seção nativa "Ações" do front_page.rpy do          #
# #            Launcher, combinando perfeitamente com a interface padrão.        #
# # Versao: 1.3 Alpha                                                            #
# # Data: 02/09/2026                                                             #
# # Destino: /media/Luana/home2/programas/renpy-8.3.4-sdk/renpy_mod_tools.sh     #
# # Como Compilar: Execute chmod +x renpy_mod_tools.sh para dar permissão        #
# ################################################################################

echo "=========================================================="
echo "Ren'Py SDK Mod Patcher - Por Luana"
echo "=========================================================="
echo "Digite o caminho completo para a pasta do seu Ren'Py SDK:"
echo "(Ex: /media/Luana/home2/programas/renpy-8.3.4-sdk)"
read -r SDK_PATH

# Remove a barra final, se houver
SDK_PATH=${SDK_PATH%/}
LAUNCHER_PATH="$SDK_PATH/launcher/game"
FRONT_PAGE="$LAUNCHER_PATH/front_page.rpy"

if [ ! -d "$LAUNCHER_PATH" ]; then
    echo "Erro: Pasta do launcher não encontrada em $LAUNCHER_PATH."
    echo "Certifique-se de fornecer o caminho correto do Ren'Py SDK."
    exit 1
fi

if [ ! -f "$FRONT_PAGE" ]; then
    echo "Erro: Arquivo front_page.rpy não encontrado. SDK não suportado ou corrompido."
    exit 1
fi

echo "Criando as funções do Mod no SDK..."

# 1. Cria o arquivo Python com as funções de backend
cat << 'EOF_MOD' > "$LAUNCHER_PATH/luana_sdk_mods.rpy"
init offset = 999

init python:
    import os
    import subprocess
    import shutil

    def luana_fix_extract():
        game_dir = project.current.gamedir
        rpa_file = os.path.join(game_dir, "archive.rpa")
        
        if os.path.exists(rpa_file):
            subprocess.call(["unrpa", "-p", "./", "archive.rpa"], cwd=game_dir)
        
        for root, dirs, files in os.walk(game_dir):
            for file in files:
                if file.endswith(".rpyc"):
                    os.remove(os.path.join(root, file))

    def luana_inject_ui_tweak():
        game_dir = project.current.gamedir
        tweak_file = os.path.join(game_dir, "ui_tweak.rpy")
        
        content = """init offset = 999
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
"""
        with open(tweak_file, "w", encoding="utf-8") as f:
            f.write(content)

    def luana_build_r36s():
        base_dir = project.current.path
        lib_dir = os.path.join(base_dir, "lib")
        
        for item in ["windows-i686", "windows-x86_64", "mac-x86_64", "mac-universal", "py2-linux-i686", "py3-linux-i686"]:
            target = os.path.join(lib_dir, item)
            if os.path.exists(target):
                shutil.rmtree(target)
                
        for f in os.listdir(base_dir):
            if f.endswith(".exe") or f.endswith(".app"):
                target = os.path.join(base_dir, f)
                if os.path.isdir(target):
                    shutil.rmtree(target)
                else:
                    os.remove(target)
                    
        for root, dirs, files in os.walk(base_dir):
            for file in files:
                if file.endswith(".sh"):
                    os.chmod(os.path.join(root, file), 0o755)
EOF_MOD

echo "Injetando botões nativamente na seção de Ações do front_page.rpy..."

# 2. Cria script Python temporário para injetar os botões diretamente no front_page.rpy
cat << 'EOF_PYTHON' > "/tmp/patch_front_page.py"
import sys

front_page_path = sys.argv[1]
with open(front_page_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Evita duplicar injeções se rodar mais de uma vez
if any("luana_fix_extract" in line for line in lines):
    print("O arquivo front_page.rpy já possui as modificações.")
    sys.exit(0)

out = []
for line in lines:
    out.append(line)
    
    # Injeta no final da primeira coluna da seção de Ações
    if 'Jump("force_recompile")' in line:
        indent = line[:len(line) - len(line.lstrip())]
        out.append(indent + 'textbutton _("Injetar Menu de Ajustes de UI") action Function(luana_inject_ui_tweak)\n')
        out.append(indent + 'textbutton _("Compilar para R36s (ArkOS/DaarkOS)") action Function(luana_build_r36s)\n')
        
    # Injeta no final da segunda coluna da seção de Ações
    if 'Jump("extract_dialogue")' in line:
        indent = line[:len(line) - len(line.lstrip())]
        out.append(indent + 'textbutton _("Extrair Diálogos (unrpa + del .rpyc)") action Function(luana_fix_extract)\n')

with open(front_page_path, "w", encoding="utf-8") as f:
    f.writelines(out)

print("Injeção concluída com sucesso.")
EOF_PYTHON

# Executa o patcher Python
python3 /tmp/patch_front_page.py "$FRONT_PAGE"

# Limpa o cache do launcher do SDK para forçar a atualização visual
find "$LAUNCHER_PATH" -name "*.rpyc" -type f -delete

echo "SDK modificado! Inicie o Ren'Py SDK e verifique a seção 'Ações'."
