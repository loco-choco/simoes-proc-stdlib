; Rotinas de manipulacao e conversao de dados de char e string

jmp main

string_block : string "123"
string2_block : string "ABC"
string3_block : var #10

;---- Inicio do Programa Principal -----
main:
	; ------ Testando conversao em base 10 ------
	loadn r7, #string_block
	call string_length
	; r7 deve ter o tamanho da string de 3
	breakp
	loadn r7, #string_block ; pega o endereco da memoria com o char
	loadi r7, r7 ; pega o char no endereco da memoria
	call convert_char_base_10_to_int
	; r7 deve ter o valor do char '1' de 1
	breakp
	loadn r7, #string_block
	call convert_string_base_10_to_int
	; r7 deve ter o valor da string de 123
	breakp
	loadn r7, #string2_block
	call string_length
	; r7 deve ter o tamanho da string de 3
	breakp
	loadn r7, #string2_block ; pega o endereco da memoria com o char
	loadi r7, r7 ; pega o char no endereco da memoria
	call convert_char_base_10_to_int
	; r6 deve ter o valor de 1, ja que A nao eh um algarismo na base 10
	breakp
	loadn r7, #string2_block
	call convert_string_base_10_to_int
	; r6 deve falhar, pois essa string nao tem algarismos na base 10
	breakp
	; ------ Testando conversao em base 16 ------
	loadn r7, #string_block ; pega o endereco da memoria com o char
	loadi r7, r7 ; pega o char no endereco da memoria
	call convert_char_base_16_to_int
	; r7 deve ter o valor do char '1' de 1
	breakp
	loadn r7, #string_block
	call convert_string_base_16_to_int
	; r7 deve ter o valor da string de 291
	breakp
	loadn r7, #string2_block ; pega o endereco da memoria com o char
	loadi r7, r7 ; pega o char no endereco da memoria
	call convert_char_base_16_to_int
	; r7 deve ter o valor de 10
	breakp
	loadn r7, #string2_block
	call convert_string_base_16_to_int
	; r7 deve ter o valor de 2748
	breakp

	; ------ Testando conversao de inteiro para string ------
	loadn r7, #string3_block
	loadn r6, #9 ; 9 chars nao nulos
	loadn r5, #10 ; valor
	loadn r4, #10 ; base 10
	call convert_int_to_string
	; o string block deve ter agora os chars "10", para conferirmos se eh verdade vamos fazer a conversao inversa
	; nao precisamos setar r7 novamentem, pois o codigo de erro esta em r6
	call convert_string_base_10_to_int
	; r7 deve ter o valor 10 agora
	breakp

	loadn r7, #string3_block
	loadn r6, #9 ; 9 chars nao nulos
	loadn r5, #10 ; valor
	loadn r4, #2 ; base 10
	call convert_int_to_string
	; o string block deve ter agora os chars "1010", para conferirmos se eh verdade vamos fazer a conversao inversa
	; nao precisamos setar r7 novamentem, pois o codigo de erro esta em r6
	call convert_string_base_10_to_int
	; r7 deve ter o valor 1010 agora
	breakp
	halt
; Fim do programa - Para o Processador
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Biblioteca -----

;---- Rotinas Gerais de String ----
string_length:			; Rotina de encontrar o tamanho da string
				; Argumentos:
				; r7 = ponteiro da string
				; Retorno:
				; r7 = tamanho da string
	push r0 ; 0
	push r1 ; tamanho da string
	push r2 ; *(r7)
	loadn r0, #0
	loadn r1, #0
	loadi r2, r7
	cmp r2, r0
	jeq string_length_loop_exit ; string de tamanho 0
string_length_loop:
	inc r1
	inc r7
	loadi r2, r7
	cmp r2, r0
	jne string_length_loop ; while(*(r7) != NULL)
string_length_loop_exit:
	mov r7, r1 ; r7 toma o tamanho da string
	pop r2
	pop r1
	pop r0
	rts

string_copy:			; Rotina de copiar a string de um endereco para outro
				; Argumentos:
				; r7 = endereco da string original
				; r6 = endereco da copia
				; Retorno: nenhum
	push r0 ; 0
	push r1 ; char_original
	push r6 ; char * s_copy
	push r7 ; char * s
string_copy_loop: ; do {
	loadi r1, r7 ; char_original = *s;	
	storei r6, r1 ; *(s_copy) = char_original
	inc r6 ; vai para a prox pos no s_copy
	inc r7 ; vai para a prox pos no s
	cmp r1, r0
	jne string_copy_loop ; } while( char_original != '\0')
string_copy_loop_end:
	pop r7
	pop r6
	pop r1
	pop r0
	rts
	
string_reverse:			; Rotina de inverter a string, editando ela no endereco
				; Argumentos:
				; r7 = endereco da string
				; Retorno: nenhum
	push r0 ; pos
	push r1 ; pos_reverse
	push r2 ; c_pos
	push r7 ; size e depois c_pos_reverse
	mov r0, r7 ; pos = endereco string
	call string_length
	add r1, r0, r7 ; pos + string_length
	dec r1 ; pos_reverse = pos + string_length - 1
string_reverse_loop_check:
	cmp r0, r1
	jeg string_reverse_loop_end ; while (pos < pos_reverse) {
string_reverse_loop:
	loadi r2, r0 ; c_pos = s[pos]
	loadi r7, r1 ; c_pos_reverse = s[pos_reverse]
	storei r1, r2 ; s[pos_reverse] = c_pos
	storei r0, r7 ; s[pos] = c_pos_reverse
	inc r0 ; pos++
	dec r1 ; pos --
	jmp string_reverse_loop_check
string_reverse_loop_end: ; }
	pop r7
	pop r2
	pop r1
	pop r0
	rts

;---- Rotinas de Conversao String para INT ----
convert_char_base_10_to_int:	; Rotina de converter char para inteiro, base 10
				; Argumentos:
				; r7 = caractere para ser convertido
				; Retorno:
				; r7 = valor de retorno
				; r6 = codigo de erro: 0 -> convertido; 1 -> nao eh um inteiro base 10
	loadn r6, #'9' ; usado para auxiliar nas comparacoes
	cmp r7, r6
	jgr convert_char_base_10_to_int_wrong_char ; r7 > '9'
	loadn r6, #'0' 
	cmp r7, r6
	jle convert_char_base_10_to_int_wrong_char ; r7 < '0'
	sub r7, r7, r6 ; r7 = r7 - '0' -> calculo de ascii de 0-9 para inteiro
	loadn r6, #0 ; convertido
	rts
convert_char_base_10_to_int_wrong_char:
	loadn r6, #1 ; o char nao eh de 0 - 9
	rts
	

convert_string_base_10_to_int:	; Rotina de converter string para inteiro.
			; Argumentos: 
			; r7 = pointeiro do inicio da string
			; Retorno:
			; r7 = valor convertido da string
			; r6 = codigo de erro: 0 -> convertido; 1 -> nao eh um inteiro; 2 -> overflow no inteiro
	push r0 ; 0
	push r1 ; valor da saida atual
	push r2 ; numero de casas a serem convertidas
	push r3 ; valor da casa (10**r2)
	push r4 ; ponteiro da string
	push r5 ; 10

	loadn r0, #0
	loadn r1, #0
	loadn r3, #1  ; valor da primeira casa decimal
	loadn r5, #10 ; cada casa decimal tem valor de 10
	mov r4, r7 ; r4 aponta para o inicio da string
	call string_length ; temos agora o tamanho da string
	mov r2, r7 ; que eh o numero de casas do numero
	add r4, r4, r7 ; r4 (inicio + tamanho) aponta agora para o char de finalizacao da string ('\0)
convert_string_base_10_to_int_loop:
	dec r4 ; vai para o char anterior
	mov r7, r4 ; pega o endero do char anterior
	loadi r7, r7 ; pega o char do endereco apontado por r7
	call convert_char_base_10_to_int
	; em r7 temos o valor
	; em r6 o codigo se o valor eh valido, se nao for (r6 != 0), retornar agora
	cmp r6, r0
	jne convert_string_base_10_to_int_return 
	; r6 != 0, portanto o char nao eh um inteiro, retornemos agora com r6 setado
	mul r7, r7, r3 
	; valor_unidade = valor_unidade * valor_da_casa
	add r1, r1, r7 ; valor_saida += valor_unidade
	jov convert_string_base_10_to_int_overflow ; deu overflow na operacao anterior, retornar que o numero na string eh grande de mais
	mul r3, r3, r5 ; valor_da_casa = valor_da_casa * 10, para termos o valor da casa seguinte que eh 10**casa
	dec r2 ; reduz o numero de casa decimais a ser convertidas
	cmp r2, r0
	jne convert_string_base_10_to_int_loop ; while (casa_decimal != 0), pois quando o numero de casa decimais a ser convertidas for zero, entao nao tem mais unidades para somar
	mov r7, r1 ; move o resultado das somas para r7
	loadn r6, #0
	jmp convert_string_base_10_to_int_return ; retorna o valor determinado
convert_string_base_10_to_int_overflow:
	loadn r6, #2 ; codigo de overflow
convert_string_base_10_to_int_return:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

convert_char_base_16_to_int:	; Rotina de converter char para inteiro, base 16
				; Argumentos:
				; r7 = caractere para ser convertido
				; Retorno:
				; r7 = valor de retorno
				; r6 = codigo de erro: 0 -> convertido; 1 -> nao eh um inteiro base 16

	loadn r6, #'0' 
	cmp r7, r6
	jle convert_char_base_10_to_int_wrong_char ; r7 < '0'
	loadn r6, #'9' ; usado para auxiliar nas comparacoes
	cmp r7, r6
	jel convert_char_base_16_to_int_0_9 ; r7 <= '9'
	; r7 entre 0 e 9
	loadn r6, #'A' 
	cmp r7, r6
	jle convert_char_base_10_to_int_wrong_char ; r7 < 'A'
	loadn r6, #'F' ; usado para auxiliar nas comparacoes
	cmp r7, r6
	jel convert_char_base_16_to_int_A_F ; r7 <= 'F'
	; r7 entre A e F
	loadn r6, #'a' 
	cmp r7, r6
	jle convert_char_base_10_to_int_wrong_char ; r7 < 'a'
	loadn r6, #'f' ; usado para auxiliar nas comparacoes
	cmp r7, r6
	jel convert_char_base_16_to_int_a_f ; r7 <= 'f'
	; r7 entre A e F
convert_char_base_16_to_int_wrong_char:
	loadn r6, #1 ; o char nao eh de 0 - 9
	rts
convert_char_base_16_to_int_0_9:
	loadn r6, #'0'
	sub r7, r7, r6 ; r7 = r7 - '0' -> calculo de ascii de 0-9 para inteiro
	jmp convert_char_base_16_to_int_return
convert_char_base_16_to_int_A_F:
	loadn r6, #10
	add r7, r7, r6
	loadn r6, #'A'
	sub r7, r7, r6 ; r7 = r7 - 'A' + 10 -> calculo de ascii de A-F para inteiro
	jmp convert_char_base_16_to_int_return
convert_char_base_16_to_int_a_f:
	loadn r6, #10
	add r7, r7, r6
	loadn r6, #'a' ;
	sub r7, r7, r6 ; r7 = r7 - 'a' + 10 -> calculo de ascii de a-f para inteiro
convert_char_base_16_to_int_return:
	loadn r6, #0
	rts

convert_string_base_16_to_int:	; Rotina de converter string para inteiro.
			; Argumentos: 
			; r7 = pointeiro do inicio da string
			; Retorno:
			; r7 = valor convertido da string
			; r6 = codigo de erro: 0 -> convertido; 1 -> nao eh um inteiro; 2 -> overflow no inteiro
	push r0 ; 0
	push r1 ; valor da saida atual
	push r2 ; numero de casas a serem convertidas
	push r3 ; valor da casa (16**r2)
	push r4 ; ponteiro da string
	push r5 ; 10

	loadn r0, #0
	loadn r1, #0
	loadn r3, #1  ; valor da primeira casa decimal
	loadn r5, #16 ; cada casa decimal tem valor de 16
	mov r4, r7 ; r4 aponta para o inicio da string
	call string_length ; temos agora o tamanho da string
	mov r2, r7 ; que eh o numero de casas do numero
	add r4, r4, r7 ; r4 (inicio + tamanho) aponta agora para o char de finalizacao da string ('\0)
convert_string_base_16_to_int_loop:
	dec r4 ; vai para o char anterior
	mov r7, r4 ; pega o endero do char anterior
	loadi r7, r7 ; pega o char do endereco apontado por r7
	call convert_char_base_16_to_int
	; em r7 temos o valor
	; em r6 o codigo se o valor eh valido, se nao for (r6 != 0), retornar agora
	cmp r6, r0
	jne convert_string_base_16_to_int_return 
	; r6 != 0, portanto o char nao eh um inteiro, retornemos agora com r6 setado
	mul r7, r7, r3 
	; valor_unidade = valor_unidade * valor_da_casa
	add r1, r1, r7 ; valor_saida += valor_unidade
	jov convert_string_base_16_to_int_overflow ; deu overflow na operacao anterior, retornar que o numero na string eh grande de mais
	mul r3, r3, r5 ; valor_da_casa = valor_da_casa * 16, para termos o valor da casa seguinte que eh 16**casa
	dec r2 ; reduz o numero de casa decimais a ser convertidas
	cmp r2, r0
	jne convert_string_base_16_to_int_loop ; while (casa_decimal != 0), pois quando o numero de casa decimais a ser convertidas for zero, entao nao tem mais unidades para somar
	mov r7, r1 ; move o resultado das somas para r7
	loadn r6, #0
	jmp convert_string_base_16_to_int_return ; retorna o valor determinado
convert_string_base_16_to_int_overflow:
	loadn r6, #2 ; codigo de overflow
convert_string_base_16_to_int_return:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;---- Rotina de Conversao INT para String ----
int_symbols: string "0123456789abcdef"
convert_int_to_string:	; Rotina de converter inteiro para representacao em base qualquer
; Inspirado no codigo em https://learn.saylor.org/mod/book/view.php?id=33001&chapterid=12849, mas sem ser recursivo
				; Argumentos:
				; r7 = char *s, endereco onde a string sera escrita
				; r6 = max_size, tamanho maximo que a string pode ter, nao incluindo o '\0'
				; r5 = valor, valor para ser convertido
				; r4 = base, base para se converter, de 2 - 16 apenas
				; Retorno: 
				; r6 = codigo de erro: 0 -> convertido, 1 -> tamanho estourado
	push r0 ; 0, e constantes
	push r1 ; char* s
	push r2 ; tamanho atual da string
	push r3 ; symbol_to_use
	push r5 ; valor a ser convertido
	loadn r0, #0
	mov r1, r7
	loadn r2, #0
	cmp r2, r6
	jeq convert_int_to_string_loop_end ; tamanho maximo eh zero, portanto nao tem o que converter
convert_int_to_string_loop:
	mod r3, r5, r4 ; valor % base -> algarismo
	loadn r0, #int_symbols
	add r3, r0, r3 ; *(int_symbols[valor % base])
	loadi r3, r3 ; int_symbols[valor % base]
	storei r1, r3 ; *s = int_symbols[valor % base]
	
	div r5, r5, r4 ; valor = valor / base
	inc r1 ; s++, vai para a proximo posicao na string
	inc r2 ; tamanho_atual++
	loadn r0, #0
	cmp r5, r0
	jeq convert_int_to_string_loop_end ; valor == 0, portanto terminamos a conversao
	cmp r2, r6
	jle convert_int_to_string_loop ; ainda nao atingimos o tamanho maximo, voltar no loop
convert_int_to_string_loop_end:
	loadn r0, #0
	storei r1, r0 ; coloca '\0' no fim da string
	loadn r6, #0 ; conseguimos converter
	call string_reverse ; inverte a string, colocando os algarismos na ordem certa
	jmp convert_int_to_string_return
convert_int_to_string_not_enough_space:
	loadn r6, #1 ; espaco faltando para converter
convert_int_to_string_return:
	pop r5
	pop r3
	pop r2
	pop r1
	pop r0
	rts


