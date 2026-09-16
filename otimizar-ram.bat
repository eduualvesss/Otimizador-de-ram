@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title Otimizador de RAM
color 0A

REM Nao eh magica: RAM livre sobrando nao serve pra nada, o Windows
REM usa ela como cache. O que da resultado de verdade aqui eh:
REM   - matar processo de fundo que nao precisa estar aberto
REM   - forcar processo pesado a devolver pagina ociosa (working set trim)
REM   - fechar app que ta consumindo memoria sem motivo
REM Firefox, Discord e Spotify sao Electron/multi-processo por natureza,
REM entao vao sempre pesar. Fechar aba/reduzir extensao ajuda mais que
REM qualquer "RAM cleaner".

:menu
cls
echo ============================================================
echo               OTIMIZADOR DE MEMORIA RAM
echo ============================================================
echo.
echo  [1] Ver top 15 processos que mais consomem RAM
echo  [2] Compactar memoria de processos ativos (working set trim)
echo  [3] Matar processos de fundo do Discord/Spotify (nao fecha o app)
echo  [4] Limpar temporarios, cache DNS, prefetch, thumbnails
echo  [5] Reiniciar o Explorer.exe (libera RAM do shell)
echo  [6] Rodar tudo (2 a 5)
echo  [7] Fechar Firefox, Discord e Spotify de vez
echo  [0] Sair
echo.
set /p opcao="Escolha uma opcao: "

if "%opcao%"=="1" goto verprocessos
if "%opcao%"=="2" (call :do_trim & pause & goto menu)
if "%opcao%"=="3" (call :do_matahelpers & pause & goto menu)
if "%opcao%"=="4" (call :do_limpeza & pause & goto menu)
if "%opcao%"=="5" (call :do_explorer & pause & goto menu)
if "%opcao%"=="6" (call :do_trim & call :do_matahelpers & call :do_limpeza & call :do_explorer & echo Tudo rodado. & pause & goto menu)
if "%opcao%"=="7" goto fecharapps
if "%opcao%"=="0" exit /b
goto menu

:verprocessos
cls
echo Top 15 processos por uso de RAM:
echo.
powershell -NoProfile -Command "Get-Process | Sort-Object WS -Descending | Select-Object -First 15 ProcessName, Id, @{N='RAM_MB';E={[math]::Round($_.WS/1MB,1)}} | Format-Table -AutoSize"
echo.
pause
goto menu

:do_trim
echo Compactando working set de todos os processos...
echo (forca cada processo a devolver pagina ociosa pro Windows.
echo  Se o processo continuar ativo, a RAM sobe nele de novo rapido.)
powershell -NoProfile -Command "Get-Process | ForEach-Object { try { $_.MinWorkingSet = $_.MinWorkingSet } catch {} }; Write-Host 'Trim concluido.'"
exit /b

:do_matahelpers
echo Matando processos de fundo do Discord/Spotify...
taskkill /F /IM SpotifyWebHelper.exe >nul 2>&1 && echo - SpotifyWebHelper.exe finalizado || echo - SpotifyWebHelper.exe nao estava rodando
taskkill /F /IM Spotify.UpdateService.exe >nul 2>&1 && echo - Spotify.UpdateService.exe finalizado || echo - Spotify.UpdateService.exe nao estava rodando
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter 'Name=''Update.exe''' | Where-Object { $_.ExecutablePath -like '*Discord*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue; Write-Host '- Discord Update.exe finalizado' }"
taskkill /F /IM plugin-container.exe >nul 2>&1 && echo - plugin-container.exe (Firefox) finalizado || echo - plugin-container.exe nao estava rodando
echo Discord, Spotify e Firefox continuam abertos, so morreu processo de apoio.
exit /b

:do_limpeza
echo Limpando temporarios, cache DNS, prefetch, thumbnails...
del /q /f /s "%temp%\*" >nul 2>&1
del /q /f /s "C:\Windows\Prefetch\*" >nul 2>&1
del /q /f "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo Limpeza concluida. (Prefetch pode falhar sem admin, sem problema.)
exit /b

:do_explorer
echo Reiniciando o Explorer.exe...
taskkill /F /IM explorer.exe >nul 2>&1
start explorer.exe
echo Feito.
exit /b

:fecharapps
cls
echo Isso fecha Firefox, Discord e Spotify AGORA, sem salvar nada.
echo Abas abertas no Firefox, mensagem nao enviada no Discord: perdido.
set /p confirm="Confirma (S/N)? "
if /i not "%confirm%"=="S" goto menu
taskkill /F /IM firefox.exe >nul 2>&1
taskkill /F /IM Discord.exe >nul 2>&1
taskkill /F /IM Spotify.exe >nul 2>&1
echo Fechado.
pause
goto menu
