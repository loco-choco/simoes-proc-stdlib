; Rotinas de saida de dados

jmp main

string_block: string "Hello World!"
string_too_big_for_display: string "
Alias laudantium sit quis nihil harum explicabo et. Ipsam minus aut voluptate. Impedit exercitationem repellat rerum occaecati autem facilis est. Aspernatur deleniti doloribus ut consequatur non aut voluptatem delectus.

Molestias assumenda porro ut laboriosam. Est est aut doloremque doloremque cum ut dolor. Totam est nisi libero ratione. Consequatur excepturi neque qui est et soluta voluptas voluptatibus.

Veniam aut porro repellendus atque voluptas mollitia a et. Qui autem numquam totam commodi dolor odit nobis adipisci. Perferendis vel odio sit ut amet est. Nemo fugit atque nihil nobis praesentium voluptatem non aspernatur. Sunt quo ea dignissimos quia. Facere animi et aperiam officia fuga similique.

Ab cupiditate eius ducimus veritatis eum illum. Facere unde perspiciatis ut quisquam est dolor. Praesentium asperiores maiores tempora maiores quis et. Reprehenderit alias omnis et soluta voluptatem ad quis. Similique voluptatem cupiditate odit vel beatae consectetur.

Quo nihil accusantium odio. Sed quo omnis harum. Tenetur qui esse suscipit. Quod explicabo natus aut alias laboriosam ex. Dolores quo error nobis molestiae amet architecto. Aspernatur aut cupiditate tempora facilis culpa sed recusandae ut."

;---- Inicio do Programa Principal -----
main:
	; setar o tamanho da tela
	; no simulador ela eh 40 x 30
	loadn r7, #40
	call drawing_screen_width

	; setar o tamanho do canvas
	loadn r7, #20
	loadn r6, #15
	call canvas_set_resolution

	; setar a posicao da origem do canvas
	loadn r7, #10
	loadn r6, #7
	call canvas_set_origin

	; setar a posicao inicial do cursor do canvas
	loadn r7, #0
	loadn r6, #0
	call canvas_move_cursor_xy

	; printar char vermelho
	loadn r7, #':'
	loadn r6, #2304 ; vermelho
	call print_char
	breakp

	; desenhar char na posicao atual do cursor (ao lado do anterior)
	loadn r7, #'K'
	loadn r6, #2048 ; cinza
	call draw_char
	breakp

	; printar string (vai sobreescrever o char anterior)
	loadn r7, #string_block
	loadn r6, #3328 ; rosa
	call print_string
	breakp

	; printar string (nao ira completar, e r7 estara em 1)
	loadn r7, #string_too_big_for_display
	loadn r6, #0 ; branco
	call print_string
	breakp
	; printar string com overflow, significa que ira voltar na origem e continuar ate toda a mensagem estar escrita
	loadn r7, #string_too_big_for_display
	loadn r6, #2816 ; amarelo 
	call print_string_overflow
	breakp
	halt
; Fim do programa - Para o Processador
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Biblioteca -----
screen_width: var #1
canvas_cursor_pos_x: var #1
canvas_cursor_pos_y: var #1
canvas_cursor_pos: var #1
canvas_resolution_x: var #1
canvas_resolution_y: var #1
canvas_start_pos_x: var #1
canvas_start_pos_y: var #1

drawing_screen_width:	; Rotina de setar a resolucao horizontal da tela
			; Argumentos:
			; r7 = screen_width, resolucao horizontal da tela
			; Retorno: nenhum
	store screen_width, r7
	rts


canvas_set_resolution:	; Rotina de setar a resolucao do canvas.
			; Argumentos:
			; r7 = res_x, resolucao em x
			; r6 = res_y, resolucao em y
			; Retorno: nenhum
	store canvas_resolution_x, r7
	store canvas_resolution_y, r6
	rts

canvas_set_origin:	; Rotina de setar a origem do canvas.
			; Argumentos:
			; r7 = pos_x, origem em x
			; r6 = pos_y, origem em y
			; Retorno: nenhum
	store canvas_start_pos_x, r7
	store canvas_start_pos_y, r6
	rts

canvas_move_cursor_xy:	; Rotina de mover o cursor do canvas por x e y.
			; Argumentos:
			; r7 = pos_x, pos em x
			; r6 = pos_y, pos em y
			; Retorno:
			; r7 = codigo de erro: 0 -> moveu; 1 -> x > resolucao_x; 2 -> y > resolucao_y
	push r0 ; constantes
	load r0, canvas_resolution_y
	cmp r6, r0
	jeg canvas_move_cursor_xy_y_too_big
	load r0, canvas_resolution_x
	cmp r7, r0
	jeg canvas_move_cursor_xy_x_too_big
	store canvas_cursor_pos_x, r7
	store canvas_cursor_pos_y, r6
	mul r0, r0, r6 ; pos_y * res_x
	add r7, r0, r7 ; x + y * res_x
	store canvas_cursor_pos, r7 ; guardar a posicao linear no canvas
	loadn r7, #0 ; conseguimos mover, colocar codigo 0
	jmp canvas_move_cursor_xy_return
canvas_move_cursor_xy_x_too_big:
	loadn r7, #1
	jmp canvas_move_cursor_xy_return
canvas_move_cursor_xy_y_too_big:
	loadn r7, #2
canvas_move_cursor_xy_return:
	pop r0
	rts

canvas_move_cursor:	; Rotina de mover o cursor do canvas.
			; Argumentos:
			; r7 = pos, posicao linear
			; Retorno:
			; r7 = codigo de erro: 0 -> moveu; 1 -> alem do fim do canvas
	push r0 ; consts
	push r6 ; pos_y
	load r0, canvas_resolution_x
	div r6, r7, r0 ; pos_y = pos / res_x
	mod r7, r7, r0 ; pos_x = pos % res_x
	call canvas_move_cursor_xy
	loadn r0, #0
	cmp r7, r0
	jeq canvas_move_cursor_return ; se o retorno de canvas_move_cursor_xy nao for 0, entao o valor a pos vai alem do canvas
canvas_move_cursor_too_big:
	loadn r7, #1
canvas_move_cursor_return:
	pop r6
	pop r0
	rts

draw_char:		; Rotina de desenhar o caracter na posicao atual do cursor no canvas
			; Argumentos:
			; r7 = char, caracter para desenhar
			; r6 = color, cor do caracter
			; Retorno: nenhum
	push r0 ; consts e char com cor
	push r1 ; posicao para out_char
	load r1, canvas_cursor_pos_y
	load r0, canvas_start_pos_y
	add r1, r1, r0 ; (y + y0)
	load r0, screen_width
	mul r1, r1, r0 ; (y + y0) * W
	load r0, canvas_cursor_pos_x
	add r1, r1, r0 ; x + (y + y0) * W
	load r0, canvas_start_pos_x
	add r1, r1, r0 ; x + x0 + (y + y0) * W
	add r0, r7, r6 ; char_out = char + color
	outchar r0, r1 ; desenha char com cor color na pos (x + x0 + (y + y0) * W) 
	pop r1
	pop r0
	rts

print_char:		; Rotina de printar o caracter na posicao atual do cursor no canvas, e mover o cursor para a posicao seguinte
			; Argumentos:
			; r7 = char, caracter para printar
			; r6 = color, cor do caracter
			; Retorno: 
			; r7 = aviso de fim de canvas, setado caso printou na ultima posicao do buffer
	call draw_char
	load r7, canvas_cursor_pos
	inc r7 ; canvas_cursor_pos + 1
	call canvas_move_cursor ; a rotina vai retornar 1 caso chegamos no fim, e ira andar o cursor um para frente
	rts

print_string:		; Rotina de printar uma string a partir da posicao atual
			; Argumentos:
			; r7 = char* s, endereco da string
			; r6 = color, cor da string
			; Retorno:
			; r7 = aviso de fim de canvas, setado caso chegamos ou tenhamos ultrapassado a ultima posicao do buffer, a string eh cortada caso ela ultrapasse
	push r0; 0
	push r1 ; char * s
	loadn r0, #0
	mov r1, r7
	loadi r7, r1 ; r7 tem o caracter
	cmp r7, r0 ; r7 == '\0'
	jeq print_string_return ; string vazia, nao printar nem mover cursor
print_string_loop:
	call print_char
	cmp r7, r0 ; r7 != 0, portanto fim de buffer
	jne print_string_return
	inc r1
	loadi r7, r1 ; proximo char
	cmp r7, r0
	jne print_string_loop ; r7 != '\0', continuar printando
	; se chegou aqui terminamos de printar sem chegar no fim, e r7 esta com 0 ('\0') 
print_string_return:
	pop r1
	pop r0
	rts

print_string_overflow:		; Rotina de printar uma string a partir da posicao atual, com overflow. Caso o fim seja atingido, ele parte da origem do canvas
			; Argumentos:
			; r7 = char* s, endereco da string
			; r6 = color, cor da string
			; Retorno: nenhum
	push r0; 0
	push r1 ; char * s
	push r7 ; char atual
	loadn r0, #0
	mov r1, r7
	loadi r7, r1 ; r7 tem o caracter
	cmp r7, r0 ; r7 == '\0'
	jeq print_string_overflow_return ; string vazia, nao printar nem mover cursor
print_string_overflow_loop:
	call print_char
	cmp r7, r0 ; r7 != 0, portanto fim de buffer, voltar cursor ao inicio
	jeq print_string_overflow_loop_reset_cursor_end
print_string_overflow_loop_reset_cursor:
	push r7
	mov r7, r0
	call canvas_move_cursor
	pop r7 ; push e pop mais facil do que de usar um novo registrador
print_string_overflow_loop_reset_cursor_end:
	inc r1
	loadi r7, r1 ; proximo char
	cmp r7, r0
	jne print_string_overflow_loop ; r7 != '\0', continuar printando
	; se chegou aqui terminamos de printar sem chegar no fim, e r7 esta com 0 ('\0') 
print_string_overflow_return:
	pop r7
	pop r1
	pop r0
	rts
