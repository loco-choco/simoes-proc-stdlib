# Printf

Essas sao rotinas para lidar com saida de dados para a tela.

Se voce pretende ter saida numerica, recomendo ver as rotinas de manipulacao e conversao de string na pasta "data-manipulation".

Elas se baseiam em um sistema de "canvas". Um "canvas" é um espaco em que a aplicacao fica contida para desenhar ou printar, parecido com uma janela flutuante que pode ter seu tamanho alterado.

Ha tambem o sistema de "cursor" em jogo. "Cursor" é a posicao no "canvas" em que o proximo caracter será desenhado. Esse cursor sempre fica dentro do canvas, se a manipulacao dele ocorrer atraves das rotinas de canvas_move_cursor.

** Atencao, nesse documento o termo _desenhar_ é usado como sinonimo de fazer o caracter aparecer na tela, porem sem mover o cursor, já _printar_ implica que o cursor moveu para a próxima posicao **

Todas as rotinas estao documentadas no proprio arquivo fonte, com um exemplo de uso.
## Rotinas

### drawing_screen_width

Rotina para setar a resolucao horizontal da tela. No simulador a resolucao total é de 40 x 30, portante passe para essa rotina o valor de 40.

Argumentos:
- r7: screen_width; resolucao horizontal da tela

Retorno:
Nenhum.

### canvas_set_resolution

Rotina para setar a resolucao do canvas. Esse valor nao é limitado pela resolucao da tela, mas para o correto comportamente evite ir alem.

Argumentos:
- r7: res_x; resolucao horizontal do canvas
- r6: res_y; resolucao vertical do canvas

Retorno:
Nenhum.

### canvas_set_origin

Rotina para setar a origem do canvas. Esse valor nao é limitado pela resolucao da tela, mas para o correto comportamente evite a origem mais a resolucao de ir alem.

Argumentos:
- r7: pos_x; origem horizontal do canvas
- r6: pos_y; origem vertical do canvas

Retorno:
Nenhum.

### canvas_move_cursor_xy

Rotina para mover o cursor do canvas em coordenadas x,y.

Argumentos:
- r7: pos_x; posicao em x desejada
- r6: pos_y; posicao em y desejada

Retorno:
- r7: codigo de erro:
    - 0 -> consegui mover
    - 1 -> pox_x maior que resolucao do canvas
    - 2 -> pos_y maior que resolucao do canvas

### canvas_move_cursor

Rotina para mover o cursor do canvas em coordenadas lineares (como se fosse um buffer linear).

Argumentos:
- r7: pos; posicao linear desejada

Retorno:
- r7: codigo de erro:
    - 0 -> consegui mover
    - 1 -> pos está alem do fim do canvas

### draw_char

Rotina para desenhar o caracter na posicao atual do cursor no canvas (nao move o cursor).

Argumentos:
- r7: char; caracter para desenhar
- r6: color; código da cor do caracter no desenho

Retorno:
Nenhum.

### print_char

Rotina para printar o caracter na posicao atual do cursor no canvas (move o cursor).

Argumentos:
- r7: char; caracter para printar
- r6: color; código da cor do caracter no desenho

Retorno:
- r7: aviso de fim de canvas; caso setado indica que o cursor atingiu o final do canvas, e que está parado la

### print_string

Rotina para printar a string a partir da posicao atual do cursor no canvas (move o cursor).

Argumentos:
- r7: string_pointer; endereco da string para pritnar
- r6: color; código da cor do caracter no desenho

Retorno:
- r7: aviso de fim de canvas; caso setado indica que o cursor atingiu o final do canvas, e que está parado la

### print_string_overflow

Rotina para printar a string a partir da posicao atual do cursor no canvas (move o cursor) com overflow. Significa que irá tentar continuar da origem do canvas caso o fim seja alcancado.

Argumentos:
- r7: string_pointer; endereco da string para pritnar
- r6: color; código da cor do caracter no desenho

Retorno:
Nenhum.
