; Rotinas de entrada de dados

jmp main

string_block : var #10

;---- Inicio do Programa Principal -----
main:
	; AVISO: O simulador tem algum problema com entrada de teclado, pois ele fica intercalando chars nulos mesmo segurando a tecla, entao para melhor visualizar o efeito do scan_char e scan_string evite colocar breakp's
	call get_char
	; r7 tem o char atual do teclado, provavelmente '\0'
	;breakp
	call scan_char
	; r7 tem o char da tecla apertada, e deve ter parado execucao ate ela chegar
	;breakp
	loadn r7, #string_block
	loadn r6, #9 ; max size
	call scan_string
	; no string_block tem a string escrita, terminando a funcao apos um '\n' (nao incluso na string), ou quando o tamanho maximo for alcancado (nesse caso de 9 chars, sem incluir o '\0' final)
	breakp
	halt
; Fim do programa - Para o Processador
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Biblioteca -----

get_char:		; Rotina de ler o char atualmente apertado. Nao bloqueante.
			; Argumentos: nenhum
			; Retorno:
			; r7 = char lido no teclado
	push r0
	inchar r7
	loadn r0, #255
	cmp r7, r0
	jne get_char_return
	loadn r7, #0 ; bug de fpga de ler 255 na primeira entrada, tratar portanto como um '\0'
get_char_return:
	pop r0
	rts

old_pressed_char : var #1
	static old_pressed_char + #0, #0
scan_char:		; Rotina de esperar um char ser apertado (ser diferente de '\0'). Bloqueante.
			; Argumentos: nenhum
			; Retorno:
			; r7 = char apertado no teclado
	push r0 ; '\0'
	push r1 ; old_pressed_char
	loadn r0, #0
	load r1, old_pressed_char
	loadn r7, #0 ; comeca como char nulo
scan_char_loop:
	call get_char
	cmp r7, r1
	mov r1, r7 ; ja comparou se eh igual, agora tomar o valor para si
	jeq scan_char_loop ; enquanto o char for igual ao anteriormente apertado, ficar no loop
	cmp r7, r0
	jeq scan_char_loop ; enquanto o char for '\0', ficar no loop
	store old_pressed_char, r1
	pop r1
	pop r0
	rts

scan_string:		; Rotina de esperar uma string ser enviada (ultimo char ser '\n'). Bloqueante.
			; Argumentos: 
			; r7 = char * s, endereco do buffer para a string
			; r6 = int max_size, tamanho maximo da string (nao incluindo '\0')
			; Retorno: nenhum
	push r0 ; guarda '\n', que eh condicao de parada, depois '\0' para inserir no fim da string
	push r1 ; char * s, endereco do char da string
	push r2 ; int size, tamanho da string, para nao ultrapassar o max_size
	push r7 ; pois scan_char retorna no r7, entao copiamos seu valor para r1, e protegemos r7 do caller
	mov r1, r7
	loadn r0, #13 ; '\n'
	loadn r2, #0
scan_string_loop:
	call scan_char
	storei r1, r7
	inc r1
	inc r2
	cmp r2, r6
	jgr scan_string_loop_end ; chegamos no tamaho maximo, sair
	cmp r7, r0
	jne scan_string_loop ; o char atual ainda nao eh '\n', continuar
scan_string_loop_end:
	loadn r0, #0
	storei r1, r0 ; sobreescreve o '\n'com um '\0'
	pop r7
	pop r2
	pop r1
	pop r0
	rts
