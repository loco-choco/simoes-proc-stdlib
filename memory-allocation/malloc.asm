; Rotinas de alocacao dinamica de memoria

jmp main

block_addr_pos : var #1
block_end_addr_pos : var #1
dynamic_memory_block : var # 10

;---- Inicio do Programa Principal -----
main:
	; Configurando o espaco de memoria dinamica
	loadn r7, #4 ; addr inicial
	loadn r6, #15 ; addr final

	;---------- Teste de Alocacao ate acabar ----------
	call mem_move
	call mem_init
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de 4 + 2 = 6
	breakp
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de (4 + 2 + 2) + 2) = 10
	breakp
	loadn r7, #4
	call mem_alloc
	; esperado r7 ter o valor de 0, pois nao ha mais espaco na memoria dinamica
	breakp
	loadn r7, #1
	call mem_alloc
	; esperado r7 ter o valor de (4 + 2 + 2) + 2) + 2) = 14, pois ha um espaco exato na memoria para o tamanho 1
	breakp
	;----------- Teste de Alocacao e liberacao de memoria ----------
	call mem_init ; libera o bloco inteiro de memoria
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de (4 + 2) = 6
	breakp
	call mem_free
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de 6 novamente, pois o bloco anterior foi limpo, e ele tem o tamanho exato
	breakp
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de ((4 + 2 + 2) + 2) = 10
	breakp
	call mem_free
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de 10 novamente
	breakp
	loadn r7, #6
	call mem_free ; libera 6
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de 6 agora
	breakp
	call mem_free
	loadn r7, #1
	call mem_alloc
	breakp
	; esperado r7 ter o valor de 14, pois ele nao vai conseguir dar split no bloco de tamanho 2 (4) do inicio
	loadn r7, #1
	call mem_alloc
	breakp
	; esperado r7 ter o valor de 0, pois ele nao consegue dar split no bloco inicial de tamanho 2 (4), e nao ha mais espaco livre
	;----------- Teste de desfragmentacao da Memoria ----------
	call mem_init ; libera o bloco inteiro de memoria
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de (4 + 2) = 6
	breakp
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de ((4 + 2 + 2) + 2) = 10
	breakp
	loadn r7, #6
	call mem_free ; libera 6
	loadn r7, #10
	call mem_free ; libera 10
	loadn r7, #4
	call mem_alloc
	; esperado r7 ter o valor de 0, pois nao cabe bloco de tamanho 4
	breakp
	call mem_defrag
	loadn r7, #4
	call mem_alloc
	; esperado r7 ter o valor de 6, pois agora a memoria foi desfragmentada, e tem apenas 1 bloco
	breakp
	halt
; Fim do programa - Para o Processador
	
;---- Fim do Programa Principal -----
	
;---- Inicio das Biblioteca -----

mem_move:		;  Rotina de setar o bloco de memoria a ser gerenciado pela biblioteca
				; Argumentos:
				; r7 = block_addr, endereco onde comeca o bloco de memoria
				; r6 = block_end_addr, endereco final do bloco de memoria gerenciado
				; Retorno: nenhum
	store block_addr_pos, r7
	store block_end_addr_pos, r6
	rts

mem_init:		; Rotina de inicializacao do bloco de memoria
				; Argumentos: nenhum
				; Retorno: nenhum
	push r0
	push r1
	loadn r0, #0
	load r1, block_addr_pos
	; Setando header do bloco inicial
	storei r1, r0 ; Seta a flag 'free'
	inc r1 ; Vai para o segundo elemento da struct
	load r0, block_end_addr_pos
	storei r1, r0
	; Seta next_block para o fim do bloco
	pop r1
	pop r0
	rts

mem_alloc:		; Rotina de alocacao dinamica de memoria
				; Argumentos:
				; r7 = desired_size, tamanho do espaco a ser alocado
				; Retorno:
				; r7 = ponteiro do espaco alocado, NULL caso nao tenha conseguido
	push r0 ; #0
	push r1 ; block_end_addr
	push r2 ; pos
	push r3 ; is_free
	push r4 ; next_block
	push r5 ; generic_alg
		
	loadn r0, #0
	; Procurando espaco disponivel
	load r1, block_end_addr_pos
	load r4, block_addr_pos ; next_block = block_addr
	; do {
mem_alloc_space_search_do_while:
	mov r2, r4 ; pos = next_block
	loadi r3, r2 ; is_free = *(pos)
	inc r2
	loadi r4, r2 ; next_block = *(pos + 1)
	dec r2 ; retorna pos para valor real
	; } while (next_block != block_end_addr -> se chegamos no ultimo bloco
	; && (!is_free -> caso o bloco esteja livre 
	; || ((next_block - pos - 2 != desired_size) -> se cabe exatamente no bloco
	; && (next_block - pos - 4 < desired_size) -> se ha como dar split no bloco
	;)));
	cmp r4, r1
	jeq mem_alloc_space_search_do_while_end ; next_block == block_end_addr -> chegamos no ultimo item, sair da busca 
	cmp r3, r0
	jne mem_alloc_space_search_do_while ; !is_free -> o bloco que estamos nao esta livre, continuar procurando
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jeq mem_alloc_space_search_do_while_end ; (next_block - pos - 2 == desired_size), achamos um bloco usavel, sair
	dec r5
	dec r5 ; (next_block - pos - 2) - 2
	cmp r5, r7
	jeg mem_alloc_space_search_do_while_end ; (next_block - pos - 4 >= desired_size) -> bloco grande suficiente para slip, sair
	jmp mem_alloc_space_search_do_while ; o bloco nao eh util para alocacao exata, nem de split, continuar procurando
mem_alloc_space_search_do_while_end:
	; achamos um bloco ou chegamos no final
	; conferir se chegamos no final == sem memoria
	cmp r4, r1
	jne mem_alloc_alloc_memory ; nao estamos no fim, portanto eh um bloco alocavel
	cmp r3, r0
	jne mem_alloc_space_not_found ; estamos no fim, e nem ele esta livre, nao temos memoria
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jeq mem_alloc_alloc_memory ; (next_block - pos - 2 == desired_size) -> o bloco final tem tamanho exato, podemos alocar ainda
	inc r7
	inc r7
	cmp r5, r7 ; para podermos fazer a comparacao (next_block - pos - 4 >= desired_size) na forma (next_block - pos - 2 >= desired_size + 2)
	dec r7
	dec r7 ; voltando o valor de r7 ao original
	jeg mem_alloc_alloc_memory ; (next_block - pos - 4 >= desired_size) -> bloco final grande suficiente para split, podemos alocar ainda
	; nao temos nem como ter alocacao exata, nem split, e chegamos no fim, retornar ponteiro NULL
mem_alloc_space_not_found:
	mov r7, r0 ; ponteiro de saida eh NULL
	jmp mem_alloc_return
mem_alloc_alloc_memory:
	; sabemos que o bloco atual eh proprio para alocacao
	; primeiro vemos se eh tamanho exato
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jne mem_alloc_split_block ; (next_block - pos - 2) != desired_size -> o bloco atual eh para ser dado split
	; o bloco tem tamanho exato, apenas setar a flag de free e devolver o ponteiro
mem_alloc_exact_block:
	loadn r5, #2
	storei r2, r5 ; *(pos) = 2 -> flag de free setada como nao livre
	add r7, r2, r5 ; ponteiro de espaco alocado eh a pos + 2 de header
	jmp mem_alloc_return	
mem_alloc_split_block:
	; o bloco eh para ser dado split
	; atualizando o bloco atual ---
	loadn r5, #2
	storei r2, r5 ; *(pos) = 2 -> flag de free setada como nao livre
	add r5, r2, r5 ; (pos + 2)
	add r5, r5, r7 ; (pos + 2 + desired_size)
	inc r2
	storei r2, r5 ; *(pos + 1) = (pos + 2) + desired_size -> next_block do bloco atual apontando para o bloco a ser criado
	; criando o novo bloco ---
	storei r5, r0 ; *(pos + 2 + size) = 0 -> flag de free setada como livre, pois eh um novo bloco a ser alocado
	inc r5
	storei r5, r4 ; *(pos + 2 + size + 1) = next_block -> o novo bloco agora aponta para onde o atual estava apontando
	inc r2 ; agora r2 = pos + 2
	mov r7, r2 ; a saida tem o valor do ponteiro de pos + 2
	; fim da alocacao por split
mem_alloc_return:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

mem_free:		; Rotina de liberacao de memoria alocada
				; Argumentos:
				; r7 = memory_pointer, endereco da memoria alocada
				; Retorno: nenhum
	push r0
	push r1
	loadn r0, #0
	loadn r1, #2
	sub r1, r7, r1 ; Endereco da flag eh memory_pointer - 2
	storei r1, r0 ; Seta a flag 'free' do bloco de memoria
	pop r1
	pop r0
	rts

mem_defrag:		; Rotina de desfragmentacao de blocos de memoria livre
				; Argumentos: nenhum
				; Retorno: nenhum
	push r0 ; sempre 0
	push r1 ; block_end_addr_pos
	push r2 ; current_pos
	push r3 ; start_defrag_block_pos
	push r4 ; current_pos_free
	push r5 ; start_defrag_block_pos_free

	loadn r0, #0
	load r1, block_end_addr_pos
	load r2, block_addr_pos
	mov r3, r2 ; start_defrag_block_pos = block_addr

	; do {
mem_defrag_merging_blocks_do_while:
	loadi r5, r3 ; *(start_defrag_block_pos)
	loadi r4, r2 ; *(current_pos)
	
	cmp r4, r5
	jeq mem_defrag_found_new_defrag_block_end
	; nao achamos fim/inicio de bloco, pular o if	
mem_defrag_found_new_defrag_block:
	cmp r5, r0
	jne mem_defrag_merge_blocks_end
	; o bloco que achamos o fim eh de free, juntar eles
	mem_defrag_merge_blocks:
		inc r3
		storei r3, r2 ; *(start_block + 1) = current_pos -> junta os blocos free que sao seguidos
		dec r3 ; volta r3 ao valor original
	mem_defrag_merge_blocks_end:
	mov r3, r2 ; start_block = current_pos -> novo inicio de bloco de defragmentacao
mem_defrag_found_new_defrag_block_end:
	inc r2
	loadi r2, r2 ; current_pos = *(current_pos + 1) ; move para o proximo bloco
mem_defrag_merging_blocks_end_do_while:
	cmp r2, r1
	jne mem_defrag_merging_blocks_do_while
	; (current_pos != block_end_addr_pos) -> ha mais a ser possivelmente desfragmentado, ir para o proximo
	; ultima checagem, caso o conjunto final de blocos seja de free
	loadi r5, r3 ; *(start_defrag_block_pos)
	cmp r5, r0
	jne mem_defrag_merge_end_blocks
	; o bloco que achamos o fim eh de free, juntar eles
	mem_defrag_merge_end_blocks:
		inc r3
		storei r3, r2 ; *(start_block + 1) = current_pos -> junta os blocos free que sao seguidos
		dec r3 ; volta r3 ao valor original
	mem_defrag_merge_end_blocks_end:
mem_defrag_return:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

