1>2# : ^
'''
@echo off
:: ################################################################################
:: # renpy_mod_tools.bat                                                          #
:: # By: Luana                                                                    #
:: # GitHub: https://github.com/impfenix/                                         #
:: # Descricao: Patcher para modificar o Ren'Py SDK no Windows. Injeta funções    #
:: #            extras na seção "Ações" nativa do Launcher. Usa um truque         #
:: #            poliglota para rodar Batch e Python no mesmo arquivo.             #
:: # Versao: 1.3 Alpha                                                            #
:: # Data: 02/09/2026                                                             #
:: # Destino: Qualquer pasta no Windows (ex: Área de Trabalho)                    #
:: # Como Compilar: Não requer compilação. Dê um duplo clique para executar.      #
:: ################################################################################

:: Configura o terminal para UTF-8 (evita bugs na exibição de caracteres acentuados)
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ==========================================================
echo Ren'Py SDK Mod Patcher - Por Luana (Versao Windows)
echo ==========================================================

:: Solicita o caminho completo do SDK do Ren'Py ao usuário
set /p "SDK_PATH=Digite o caminho completo para a pasta do seu Ren'Py SDK (Ex: C:\renpy-8.3.4-sdk): "

:: Remove aspas duplas de segurança, caso o caminho tenha sido colado com elas
set "SDK_PATH=!SDK_PATH:"=!"

:: Tenta localizar o executável Python interno que já vem embutido nas pastas do Ren'Py
set "PYTHON_EXE="
if exist "!SDK_PATH!\lib\py3-windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py3-windows-x86_64\python.exe"
if exist "!SDK_PATH!\lib\py3-windows-i686\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py3-windows-i686\python.exe"
if exist "!SDK_PATH!\lib\py2-windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\py2-windows-x86_64\python.exe"
if exist "!SDK_PATH!\lib\windows-x86_64\python.exe" set "PYTHON_EXE=!SDK_PATH!\lib\windows-x86_64\python.exe"

:: Se não achar o Python do Ren'Py, avisa o erro e encerra o programa
if not defined PYTHON_EXE (
    echo Erro: Interpretador Python do Ren'Py nao encontrado na pasta do SDK.
    echo Certifique-se de que a pasta base informada esta correta.
    pause
    exit /b 1
)

:: Executa este próprio arquivo (.bat) repassando-o para o interpretador Python encontrado
"!PYTHON_EXE!" "%~f0" "!SDK_PATH!"
pause
exit /b
'''

import sys
import os
import shutil

# Captura o argumento passado pelo script Batch (o caminho base do SDK)
sdk_path = sys.argv[1]

# Mapeia onde ficam os arquivos de interface originais do Launcher do SDK
launcher_path = os.path.join(sdk_path, "launcher", "game")
front_page = os.path.join(launcher_path, "front_page.rpy")

# Verifica se os caminhos críticos realmente existem antes de prosseguir com a injeção
if not os.path.exists(launcher_path) or not os.path.exists(front_page):
    print(f"Erro: Pasta do launcher ou front_page.rpy não encontrada em {launcher_path}.")
    sys.exit(1)

print("Criando as funções do Mod no SDK...")

# String formatada contendo o código exato da tela de "Ajuste de UI" que será injetada dentro dos jogos
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

# String contendo as novas funções de backend que vão processar o jogo (serão adicionadas ao próprio SDK)
mod_content = """init offset = 999

init python:
    import os
    import subprocess
    import shutil

    def luana_fix_extract():
        # Extrai o arquivo .rpa e limpa arquivos compilados .rpyc para forçar leitura das modificações
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
        # Cria fisicamente o arquivo ui_tweak.rpy na pasta do jogo atual contendo a tela de ajuste
        game_dir = project.current.gamedir
        tweak_file = os.path.join(game_dir, "ui_tweak.rpy")
        content = """ + repr(tweak_rpy_code) + """
        with open(tweak_file, "w", encoding="utf-8") as f:
            f.write(content)

    def luana_build_r36s():
        # Limpa dependências redundantes (Mac/Windows) e dá permissões corretas para rodar em portáteis Linux ARM
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

# Salva as funções de backend em um arquivo separado na pasta do launcher (luana_sdk_mods.rpy)
with open(os.path.join(launcher_path, "luana_sdk_mods.rpy"), "w", encoding="utf-8") as f:
    f.write(mod_content)

print("Injetando botões nativamente na seção de Ações do front_page.rpy...")

# Lê todo o código original que constrói a página inicial da interface do SDK
with open(front_page, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Verifica se os botões já foram injetados anteriormente para evitar código duplicado e erros de sintaxe
if any("luana_fix_extract" in line for line in lines):
    print("O arquivo front_page.rpy já possui as modificações.")
else:
    out = []
    for line in lines:
        out.append(line)
        
        # Localiza a posição do botão "Forçar Recompilação" para injetar as novas opções abaixo dele (Coluna Esquerda)
        if 'Jump("force_recompile")' in line:
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + 'textbutton _("Injetar Menu de Ajustes de UI") action Function(luana_inject_ui_tweak)\n')
            out.append(indent + 'textbutton _("Compilar para R36s (ArkOS/DaarkOS)") action Function(luana_build_r36s)\n')
            
        # Localiza a posição do botão "Extrair Diálogos" para injetar a nova versão corrigida abaixo dele (Coluna Direita)
        if 'Jump("extract_dialogue")' in line:
            indent = line[:len(line) - len(line.lstrip())]
            out.append(indent + 'textbutton _("Extrair Diálogos (unrpa + del .rpyc)") action Function(luana_fix_extract)\n')

    # Reescreve o front_page.rpy com as novas linhas adicionadas
    with open(front_page, "w", encoding="utf-8") as f:
        f.writelines(out)

print("Removendo cache (.rpyc) do launcher...")

# Remove as versões binárias compiladas do launcher SDK. Sem isso, o Ren'Py carrega o cache antigo e a interface nova não aparece.
for root, dirs, files in os.walk(launcher_path):
    for file in files:
        if file.endswith(".rpyc"):
            try:
                os.remove(os.path.join(root, file))
            except Exception:
                pass

print("Injeção concluída com sucesso! Inicie o Ren'Py SDK e verifique a seção 'Ações'.")
