# Scanf

Essas sao rotinas para lidar com entrada de dados pelo teclado, de maneira bloqueante, ou nao.

Se voce pretende ter entrada numerica, recomendo ver as rotinas de manipulacao e conversao de string na pasta "data-manipulation".

Todas elas estao documentadas no proprio arquivo fonte, com um exemplo de uso.
## Rotinas

### get_char

Le o char atualmente apertado, fazendo a correcao da fpga retornar 255 quando deveria devolver 0.

Argumentos:
Nenhum.

Retorno:
- r7: char; char lido

### scan_char

Espera uma tecla ser apertada antes de devolver. Se a tecla ja estava apertada quando scan_char eh chamado, ele apenas ira ler ela quando a tecla for solta e apertada novamente.

**Bloqueia o processo principal ate pegar o char**

Argumentos:
Nenhum.

Retorno:
- r7: char; char lido

### scan_string

Espera o usuario escrever uma string. Considera-se a string como terminada se o usuario apertar a tecla <ENTER> ou ele escrever alem do tamanho maximo (caso no qual a string final sera o que ele escreveu ate aquele momento), o criterio da tecla estar ou nao apertada é o mesmo que no `scan_char`.

**Bloqueia o processo principal ate terminar a string**

Argumentos:
- r7: string_pointer; o endereco do array onde a string sera escrita
- r6: max_size; o tamanho maximo em chars que a string pode ter, nao incluindo o char de termino '\0'

Retorno:
Nenhum.
