; Rotinas de manipulacao e conversao de dados de char e string

jmp main

string_block : string "123"
string2_block : string "ABC"
string3_block : var #10
string4_block : string "uma BAnana"
token_buffer : var #5

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

	; ------ Testando rotinas gerais de string ------

	; string_compare
	loadn r7, #string_block
	loadn r6, #string_block
	call string_compare
	; tem o mesmo conteudo, r6 eh para estar com 0
	breakp
	loadn r7, #string2_block
	loadn r6, #string_block
	call string_compare
	; agora a string r6 vai depois que a string em r7, r6 eh um valor positivo
	breakp
	; string_copy:
	loadn r7, #string3_block
	loadn r6, #string_block
	call string_copy
	; string3_block deve ter o conteudo de string_block
	; para conferirmos vamos converter para um numero que estara em r7
	call convert_string_base_10_to_int
	; r7 deve ter o valor de 123
	breakp
	; string_concatenate:
	loadn r7, #string3_block
	loadn r6, #string_block
	call string_concatenate
	; string3_block agora deve ter o conteudo de "123123", esse numero eh grande demais para visualizar no registrador, entao iremos nele armazenar o tamanho da string que sera de 6 no r7
	call string_length
	breakp
	; string_pointer_break:
	loadn r7, #string4_block
	loadn r6, #string2_block
	call string_pointer_break
	; vai procurar pelo primeiro caracter de string3_block em string4_block
	; eh para r7 ter o endereco de A, ou seja o valor 24
	breakp
	; string_span:
	loadn r7, #string4_block
	loadn r6, #string2_block
	call string_span
	; vai procurar pelo tamanho do primeiro bloco de caracteres de string3_block em string4_block
	; eh para r6 ter o tamanho do bloco, ou seja o valor 2
	breakp
	; string_token:
	loadn r7, #string4_block
	loadn r6, #string2_block
	loadn r5, #token_buffer
	loadn r4, #4
	call string_token
	; vai encontrar o primeiro token em string4_block usando os delimitadores em string2_block e gravar em token_buffer
	; por esse token ter 4 de tamanho r6 estara marcado com 1, por estar usando todo o tamanho do buffer
	; e r7 estara na pos 24, por ser apos o fim do token
	breakp
	; para mostrar que o token foi corretamente gravado, o tamanho da string deve ser 4
	loadn r7, #token_buffer
	call string_length
	; se gravou certo, r7 = 4
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

string_compare:			; Rotina de comparar duas strings
				; Argumentos:
				; r7 = endereco da string a
				; r6 = endereco da string b
				; Retorno: 
				; r6 = <0 se o char que nao bate de a for menor que o em b, 0 se forem iguais, >0 caso o contrario
	push r0 ; 0
	push r1 ; char_a
	push r2 ; char_b
	push r7 ; char * s_b
	loadn r0, #0
string_compare_loop: ; do {
	loadi r1, r7 ; char_a = *s_a;	
	loadi r2, r6 ; char_b = *s_b;	
	inc r6 ; vai para a prox pos no s_original
	inc r7 ; vai para a prox pos no s_copia
	cmp r1, r0
	jeq string_compare_loop_end
	cmp r2, r0
	jeq string_compare_loop_end
	cmp r1, r2
	jeq string_compare_loop
string_compare_loop_end: ; } while( char_a != '\0' && char_b != '\0' && char_a != char_b)
	; agora o resultado da comparacao eh dado ao subtrair char_b de char_a
	sub r6, r1, r2
	pop r7
	pop r2
	pop r1
	pop r0
	rts

string_starts_with:		; Rotina de conferir se uma string comeca com outra
				; Argumentos:
				; r6 = endereco da string base
				; r7 = endereco da string que queremos conferir se faz parte do inicio da string base
				; Retorno: 
				; r6 = 0, se a string rm r6 fazer parte do inicio da de r7, outro valor caso nao
	push r0 ; 0
	push r1 ; char_base
	push r2 ; char_comp
	; r6, s_comp
	push r7 ; char * s_base
	loadn r0, #0
string_starts_with_loop: ; do {
	loadi r1, r7 ; char_base = *s_base;	
	loadi r2, r6 ; char_comp = *s_comp;	
	inc r6 ; vai para a prox pos no s_comp
	inc r7 ; vai para a prox pos no s_base
	cmp r1, r0
	jeq string_starts_with_loop_end
	cmp r2, r0
	jeq string_starts_with_loop_end
	cmp r1, r2
	jeq string_starts_with_loop
string_starts_with_loop_end: ; } while( char_base != '\0' && char_comp != '\0' && char_base != char_comp)
	; se chegamos aqui, e char_comp == '\0', significa que todo o inicio da s_base contem s_comp, portanto r6 = 0, se nao, r6 = char_comp
	mov r6, r2
	pop r7
	pop r2
	pop r1
	pop r0
	rts
	
string_copy:			; Rotina de copiar a string de um endereco para outro
				; Argumentos:
				; r7 = endereco do destino string
				; r6 = endereco da string original
				; Retorno: nenhum
	push r0 ; 0
	push r1 ; char_original
	push r6 ; char * s_original
	push r7 ; char * s_copia
	loadn r0, #0
string_copy_loop: ; do {
	loadi r1, r6 ; char_original = *s_original;	
	storei r7, r1 ; *(s_copia) = char_original
	inc r6 ; vai para a prox pos no s_original
	inc r7 ; vai para a prox pos no s_copia
	cmp r1, r0
	jne string_copy_loop ; } while( char_original != '\0')
string_copy_loop_end:
	pop r7
	pop r6
	pop r1
	pop r0
	rts
	
string_concatenate:		; Rotina de concaternar uma copia de uma string para uma outra de destino
				; Argumentos:
				; r7 = endereco da string destino
				; r6 = endereco da string fonte
				; Retorno: nenhum
	push r0 ; 0
	push r1 ; char_fonte
	push r6 ; char * s_fonte
	push r7 ; char * s_destino
	; temos que primeiro achar o fim da string do destino para podermos comecar a fazer append
	loadn r0, #0
string_concatenate_find_dest_end_loop_check: ; while (*s_destinho != '\0') {
	loadi r1, r7
	cmp r1, r0
	jeq string_concatenate_find_dest_end_loop_end
string_concatenate_find_dest_end_loop:
	inc r7 ; s_destino++
	jmp string_concatenate_find_dest_end_loop_check
string_concatenate_find_dest_end_loop_end: ; }

string_concatenate_loop: ; do {
	loadi r1, r6 ; char_fonte = *s_fonte;	
	storei r7, r1 ; *(s_destino) = char_fonte
	inc r6 ; vai para a prox pos no s_fonte
	inc r7 ; vai para a prox pos no s_destino
	cmp r1, r0
	jne string_copy_loop ; } while( char_fonte != '\0')
string_concatenate_loop_end:
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

string_pointer_break:		; Rotina de encontrar a posicao da primeira ocorrencia de uma caracter da string de busca na string scaneada
				; Argumentos:
				; r7 = ponteiro da string a ser scaneada
				; r6 = ponteiro da string com caracteres de busca
				; Retorno:
				; r7 = endereco do caracter encontrado
	push r0 ; 0
	push r1 ; char da string scaneada
	push r2 ; char da string de busca
	push r3 ; ponteiro da string de busca
	loadn r0, #0
string_pointer_break_loop_check: ; while(*(string_scanned) != NULL) {
	loadi r1, r7 ; r1 toma o char na pos de r7
	cmp r1, r0
	jeq string_pointer_break_loop_end
string_pointer_break_loop:
	mov r3, r6 ; vai para o inicio da string de busca
	string_pointer_break_find_loop_check: ; while(*(string_search) != NULL){
		loadi r2, r3 ; r2 toma o char na pos de r3
		cmp r2, r0
		jeq string_pointer_break_find_loop_end
	string_pointer_break_find_loop:
		cmp r1, r2
		jeq string_pointer_break_return ; se achamos o caracter da string scaneada na string de busca, retornar agora pois r7 tem o valor correto
		inc r3
		jmp string_pointer_break_find_loop_check
	string_pointer_break_find_loop_end:; } 
	inc r7 ; vai para o proximo caracter
	jmp string_pointer_break_loop_check
string_pointer_break_loop_end: ; }
	; se nao retornamos antes, entao nao encontramos nenhum char da string de busca na escaneada, retornando NULL
	mov r7, r0
string_pointer_break_return:
	pop r3
	pop r2
	pop r1
	pop r0
	rts

string_span:		; Rotina de encontrar o tamanho da porcao de caracteres da string de busca contida na string scaneada
				; Argumentos:
				; r7 = ponteiro da string a ser scaneada
				; r6 = ponteiro da string com caracteres de busca
				; Retorno:
				; r6 = tamanho do bloco de caracteres
	push r0 ; 0
	push r1 ; char da string scaneada
	push r2 ; char da string de busca
	push r3 ; ponteiro da string de busca
	push r4 ; tamanho do bloco
	push r7 ; para protecao do r7
	
	loadn r0, #0
	loadn r4, #0 ; tamanho inicia 0
string_span_loop_check: ; while(*(string_scanned) != NULL) {
	loadi r1, r7 ; r1 toma o char na pos de r7
	cmp r1, r0
	jeq string_span_loop_end
string_span_loop:
	mov r3, r6 ; vai para o inicio da string de busca
	string_span_find_loop_check: ; while(*(string_search) != NULL && *(string_search) != *(string_scanned)){
		loadi r2, r3 ; r2 toma o char na pos de r3
		cmp r2, r0
		jeq string_span_find_loop_end
		cmp r2, r1
		jeq string_span_find_loop_end
	string_span_find_loop:
		inc r3
		jmp string_span_find_loop_check
	string_span_find_loop_end:; }
	cmp r2, r0
	jeq string_span_not_in_span ; if(*(string_search) != NULL), estamos no spam 
string_span_in_span:
	inc r4 ; esse caracter eh do bloco, entao aumentar o valor em 1
	jmp string_span_in_span_end
string_span_not_in_span: ; else if(tamanho_bloco > 0), acabamos de sair do bloco, sair do loop, pois o char de busca eh nulo, aka nao encontramos
	cmp r4, r0
	jgr string_span_loop_end
string_span_in_span_end:
	inc r7 ; vai para o proximo caracter
	jmp string_span_loop_check
string_span_loop_end: ; }
	mov r6, r4 ; r6 recebe o valor do tamanho do bloco
string_span_return:
	pop r7
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

string_token:		; Rotina de extrair tokens de uma string a partir de caracteres de delimitacao
				; Argumentos:
				; r7 = ponteiro da string a ser scaneada
				; r6 = ponteiro da string com caracteres de delimitacao
				; r5 = endereco onde o token deve ser escrito (tem que ser grande o suficiente para o token)
				; r4 = tamanho do buffer em r5, nao incluindo o char de finalizacao '\0', ira parar de escrever no token e avisar no retorno, contudo ira retornar a correta posicao para a busca do token seguinte. TEM QUE SER MAIOR QUE 1.
				; Retorno:
				; r7 = aponta para a posicao final do token na string scaneada
				; r6 = codigo de erro: 0 -> consegiu escrever, 1 -> encheu completamente o buffer
	push r0 ; 0
	push r1 ; char da string scaneada
	push r2 ; char da string de delimitacao
	push r3 ; ponteiro da string de delimitacao
	push r4 ; tamanho disponivel no buffer de token
	push r5 ; ponteiro do token_buffer
	loadn r0, #0
	storei r5, r0 ; faz com que o primeiro char no buffer the token seja nulo, sera util para verificar se foi encontrado um token na string
string_token_loop_check: ; while(*(string_scanned) != NULL) {
	loadi r1, r7 ; r1 toma o char na pos de r7
	cmp r1, r0
	jeq string_token_loop_end
string_token_loop:
	mov r3, r6 ; vai para o inicio da string de busca
	string_token_find_loop_check: ; while(*(string_delimiter) != NULL && *(string_delimiter) != *(string_scanned)){
		loadi r2, r3 ; r2 toma o char na pos de r3
		cmp r2, r0
		jeq string_token_find_loop_end
		cmp r2, r1
		jeq string_token_find_loop_end
	string_token_find_loop:
		inc r3
		jmp string_token_find_loop_check
	string_token_find_loop_end:; }
	cmp r2, r0
	jne string_token_outside_token ; if(*(string_delimiter) == NULL), estamos no token
string_token_in_token:
	; estamos no token, entao copiar para o token
	cmp r4, r0
	jeq string_token_in_token_copy_end ; se o tamanho for zero, nao podemos mais inserir
	string_token_in_token_copy:
		storei r5, r1 ; copiar o char para o token_buffer
		dec r4 ; reduzir por um o tamanho maximo permitido
		cmp r4, r0
		jeq string_token_in_token_end ; apenas ir para o proximo caso nao tenhamos estourado o tamanho, necessario pois usamos o conteudo do token_buffer para determinar se estavamos em um token
		inc r5 ; ir para a proxima pos do token_buffer
	string_token_in_token_copy_end:
	jmp string_token_in_token_end
string_token_outside_token: ; else if(*(token_buffer) != NULL), acabamos de sair do bloco do token, sair do loop, pois o char de delimitacao nao eh nulo, entao ver se foi escrito no token_buffer, se sim entao estavamos no token antes, ou seja, condicao de parada
	loadi r2, r5 ; pega o char no token_buffer, usando r2 pois ele teve o seu uso no loop finalizado 
	cmp r2, r0
	jne string_token_loop_end ; nao eh NULL? entao acabamos de sair do token
string_token_in_token_end:
	inc r7 ; vai para o proximo caracter
	jmp string_token_loop_check
string_token_loop_end: ; }
	; r7 esta apontando para o local correto
	; apenas precisamos colocar o codigo de erro em r6
	; e adicionar o char de termino '\0' no token_buffer
	inc r5
	storei r5, r0 ; coloca '\0' no fim
	cmp r4, r0
	mov r6, r0 ; antes de checar assumir que nao usamos todo o buffer
	jne string_token_used_all_token_buffer_end
string_token_used_all_token_buffer:
	loadn r6, #1
string_token_used_all_token_buffer_end:
string_token_return:
	pop r5
	pop r4
	pop r3
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


