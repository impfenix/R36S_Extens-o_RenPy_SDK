1>2# : ^
'''
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ==========================================================
echo Ren'Py SDK Mod Patcher - Por Luana (Versao Windows)
echo ==========================================================
set /p "SDK_PATH=Digite o caminho completo para a pasta do seu Ren'Py SDK (Ex: C:\renpy-8.3.4-sdk): "

:: Remove aspas duplas caso o usuario tenha colado o caminho com elas
set "SDK_PATH=!SDK_PATH:"=!"

:: Tenta localizar o executavel Python interno do Ren'Py em diversos padroes de pastas (Ren'Py 7 e 8)
set "PYTHON_EXE="
if exist "!SDK_PATH!\lib\py3-windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py3-windows-x86_64\python.exe"
if exist "!SDK_PATH!\lib\py3-windows-i686\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py3-windows-i686\python.exe"
if exist "!SDK_PATH!\lib\py2-windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py2-windows-x86_64\python.exe"
if exist "!SDK_PATH!\lib\windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\windows-x86_64\python.exe"

if not defined PYTHON_EXE (
    echo Erro: Interpretador Python do Ren'Py nao encontrado na pasta do SDK.
    echo Certifique-se de que a pasta base informada esta correta.
    pause
    exit /b 1
)

:: Executa este proprio arquivo (.bat) usando o Python
"!PYTHON_EXE!" "%~f0" "!SDK_PATH!"
pause
exit /b
'''

import sys
import os
import shutil

sdk_path = sys.argv[1]
launcher_path = os.path.join(sdk_path, "launcher", "game")
front_page = os.path.join(launcher_path, "front_page.rpy")

if not os.path.exists(launcher_path) or not os.path.exists(front_page):
    print(f"Erro: Pasta do launcher ou front_page.rpy não encontrada em {launcher_path}.")
    sys.exit(1)

print("Criando as funções do Mod no SDK...")

tweak_rpy_code = """init offset = 999

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

mod_content = """init offset = 999

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
                    try:
                        os.remove(os.path.join(root, file))
                    except Exception:
                        pass

    def luana_inject_ui_tweak():
        game_dir = project.current.gamedir
        tweak_file = os.path.join(game_dir, "ui_tweak.rpy")
        content = """ + repr(tweak_rpy_code) + """
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
"""

with open(os.path.join(launcher_path, "luana_sdk_mods.rpy"), "w", encoding="utf-8") as f:
    f.write(mod_content)

print("Injetando botões nativamente na seção de Ações do front_page.rpy...")
with open(front_page, "r", encoding="utf-8") as f:
    lines = f.readlines()

if any("luana_fix_extract" in line for line in lines):
    print("O arquivo front_page.rpy já possui as modificações.")
else:
    out = []
    for line in lines:
        out.append(line)
        
        if 'Jump("force_recompile")' in line:
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + 'textbutton _("Injetar Menu de Ajustes de UI") action Function(luana_inject_ui_tweak)\n')
            out.append(indent + 'textbutton _("Compilar para R36s (ArkOS/DaarkOS)") action Function(luana_build_r36s)\n')
            
        if 'Jump("extract_dialogue")' in line:
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + 'textbutton _("Extrair Diálogos (unrpa + del .rpyc)") action Function(luana_fix_extract)\n')

    with open(front_page, "w", encoding="utf-8") as f:
        f.writelines(out)

print("Removendo cache (.rpyc) do launcher...")
for root, dirs, files in os.walk(launcher_path):
    for file in files:
        if file.endswith(".rpyc"):
            try:
                os.remove(os.path.join(root, file))
            except Exception:
                pass

print("Injeção concluída com sucesso! Inicie o Ren'Py SDK e verifique a seção 'Ações'.")
