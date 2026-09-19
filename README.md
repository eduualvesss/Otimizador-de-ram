# Otimizador-de-ram

Script `.bat` para Windows com menu interativo para liberar RAM. Lista os processos mais pesados, devolve memória ociosa ao sistema, encerra processos de apoio de apps comuns e limpa arquivos temporários.

## Antes de usar

RAM livre sobrando não serve pra nada, o Windows usa como cache de disco. O que ajuda de verdade é fechar o que consome memória sem precisar. Firefox, Discord e Spotify são multi-processo por natureza e sempre vão pesar. Fechar aba e reduzir extensão ajuda mais que qualquer "limpador de RAM".

O script automatiza essa limpeza manual. Nada além disso.

## Menu

| Opção | O que faz |
| --- | --- |
| 1 | Lista os 15 processos que mais usam RAM, em MB |
| 2 | Compacta o working set de todos os processos, forçando cada um a devolver páginas ociosas ao Windows. Se o processo continuar ativo, o uso volta a subir |
| 3 | Encerra processos de apoio: `SpotifyWebHelper.exe`, `Spotify.UpdateService.exe`, `Update.exe` do Discord e `plugin-container.exe` do Firefox. Os apps continuam abertos |
| 4 | Limpa `%temp%`, `C:\Windows\Prefetch` e o cache de miniaturas, e limpa o cache DNS |
| 5 | Reinicia o `Explorer.exe` para liberar a memória do shell |
| 6 | Roda as opções 2 a 5 em sequência |
| 7 | Fecha Firefox, Discord e Spotify na hora, com confirmação |
| 0 | Sai |

## Como usar

1. Baixe o `otimizar-ram.bat`.
2. Dê dois cliques. Para limpar o Prefetch, clique com o botão direito e execute como administrador.
3. Escolha uma opção no menu.

Sem administrador, o script pula o que não conseguir acessar e segue com o resto.

## Cuidados

- A opção 7 fecha os apps sem salvar nada. Abas do Firefox e mensagens não enviadas no Discord são perdidas.
- A opção 5 fecha as janelas abertas do Explorer e recarrega a barra de tarefas.
- Limpar o Prefetch deixa a primeira abertura de alguns programas um pouco mais lenta, até o Windows recriar os dados.
- Na limpeza de `%temp%`, arquivos em uso são ignorados.

## Requisitos

Windows com PowerShell, que já vem instalado. Sem outras dependências.
