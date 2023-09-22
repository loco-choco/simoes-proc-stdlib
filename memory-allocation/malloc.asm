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
	call mem_alloc_2
	; esperado r7 ter o valor de 4 + 2 = 6
	breakp
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de (4 + 2 + 2) + 2) = 10
	breakp
	loadn r7, #4
	call mem_alloc_2
	breakp
	; esperado r7 ter o valor de 0, pois nao ha mais espaco na memoria dinamica
	loadn r7, #1
	call mem_alloc_2
	breakp
	; esperado r7 ter o valor de (4 + 2 + 2) + 2) + 2) = 14, pois ha um espaco exato na memoria para o tamanho 1
	;----------- Teste de Alocacao e liberacao de memoria ----------
	call mem_init ; libera o bloco inteiro de memoria
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de (4 + 2) = 6
	breakp
	call mem_free
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de 6 novamente, pois o bloco anterior foi limpo, e ele tem o tamanho exato
	breakp
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de ((4 + 2 + 2) + 2) = 10
	breakp
	call mem_free
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de 10 novamente
	breakp
	loadn r7, #6
	call mem_free ; libera 6
	loadn r7, #2
	call mem_alloc_2
	; esperado r7 ter o valor de 6 agora
	breakp
	call mem_free
	loadn r7, #1
	call mem_alloc_2
	breakp
	; esperado r7 ter o valor de 14, pois ele nao vai conseguir dar split no bloco de tamanho 2 (4) do inicio
	loadn r7, #1
	call mem_alloc_2
	breakp
	; esperado r7 ter o valor de 0, pois ele nao consegue dar split no bloco inicial de tamanho 2 (4), e nao ha mais espaco livre
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

mem_alloc_2:		; Rotina de alocacao dinamica de memoria
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
mem_alloc_2_space_search_do_while:
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
	jeq mem_alloc_2_space_search_do_while_end ; next_block == block_end_addr -> chegamos no ultimo item, sair da busca 
	cmp r3, r0
	jne mem_alloc_2_space_search_do_while ; !is_free -> o bloco que estamos nao esta livre, continuar procurando
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jeq mem_alloc_2_space_search_do_while_end ; (next_block - pos - 2 == desired_size), achamos um bloco usavel, sair
	dec r5
	dec r5 ; (next_block - pos - 2) - 2
	cmp r5, r7
	jeg mem_alloc_2_space_search_do_while_end ; (next_block - pos - 4 >= desired_size) -> bloco grande suficiente para slip, sair
	jmp mem_alloc_2_space_search_do_while ; o bloco nao eh util para alocacao exata, nem de split, continuar procurando
mem_alloc_2_space_search_do_while_end:
	; achamos um bloco ou chegamos no final
	; conferir se chegamos no final == sem memoria
	cmp r4, r1
	jne mem_alloc_2_alloc_memory ; nao estamos no fim, portanto eh um bloco alocavel
	cmp r3, r0
	jne mem_alloc_2_space_not_found ; estamos no fim, e nem ele esta livre, nao temos memoria
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jeq mem_alloc_2_alloc_memory ; (next_block - pos - 2 == desired_size) -> o bloco final tem tamanho exato, podemos alocar ainda
	inc r7
	inc r7
	cmp r5, r7 ; para podermos fazer a comparacao (next_block - pos - 4 >= desired_size) na forma (next_block - pos - 2 >= desired_size + 2)
	dec r7
	dec r7 ; voltando o valor de r7 ao original
	jeg mem_alloc_2_alloc_memory ; (next_block - pos - 4 >= desired_size) -> bloco final grande suficiente para split, podemos alocar ainda
	; nao temos nem como ter alocacao exata, nem split, e chegamos no fim, retornar ponteiro NULL
mem_alloc_2_space_not_found:
	mov r7, r0 ; ponteiro de saida eh NULL
	jmp mem_alloc_2_return
mem_alloc_2_alloc_memory:
	; sabemos que o bloco atual eh proprio para alocacao
	; primeiro vemos se eh tamanho exato
	loadn r5, #2
	sub r5, r4, r5 ; (next_block - 2)
	sub r5, r5, r2 ; (next_block - 2) - pos
	cmp r5, r7
	jne mem_alloc_2_split_block ; (next_block - pos - 2) != desired_size -> o bloco atual eh para ser dado split
	; o bloco tem tamanho exato, apenas setar a flag de free e devolver o ponteiro
mem_alloc_2_exact_block:
	loadn r5, #2
	storei r2, r5 ; *(pos) = 2 -> flag de free setada como nao livre
	add r7, r2, r5 ; ponteiro de espaco alocado eh a pos + 2 de header
	jmp mem_alloc_2_return	
mem_alloc_2_split_block:
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
mem_alloc_2_return:
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

mem_alloc:		; Rotina de alocacao dinamica de memoria
				; Argumentos:
				; r7 = allocated_size, tamanho do espaco a ser alocado
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
mem_alloc_search_do_while:
	mov r2, r4 ; pos = next_block
	loadi r3, r4 ; is_free = pos[0]
	inc r4
	loadi r4, r4 ; next_block = pos[1]
	; } while(next_block!=NULL && (!is_free || ((next_block - pos - 3) < allocated_size)))
	cmp r4, r0
	jeq mem_alloc_search_do_while_end ; next_block == NULL, curto circuito
	cmp r3, r0
	jne mem_alloc_search_do_while ; is_free != 0, estando no OR, podemos ja voltar para o loop
	loadn r5, #3
	sub r5, r4, r5 ; next_block - 3
	sub r5, r5, r2 ; (next_block - 3) - pos
	cmp r5, r7
	jle mem_alloc_search_do_while ; (next_block - pos - 3) < allocated_size
mem_alloc_search_do_while_end:
	; if( next_block == NULL && (size - pos - 3) < allocated_size) return NULL
	cmp r4, r0
	jne mem_alloc_mem_found ; next_block != NULL, nao estamos no fim da memoria
	loadn r5, #3
	sub r5, r1, r5 ; block_end_addr - 3
	sub r5, r5, r2 ; (bloc_end_addr - 3) - pos
	cmp r5, r7
	jeg mem_alloc_mem_found; (block_end_addr - pos - 3) >= allocated_size, tem memoria suficente para alocar no fim do bloco
	; nao temos memoria mesmo, retornar com r7 = NULL
	mov r7, r0	
	jmp mem_alloc_return
mem_alloc_mem_found:
	; Temos um bloco de memoria livre que cabe, agora vemos se precisamos dividir ele
	; if((next_block == NULL && ( block_end_addr - pos - 3 ) == size) || (next_block != NULL &&(next_block - pos - 3) == size))
	; o bloco eh perfeito, entao marcar como usado e retornar seu endereco
	cmp r0, r4
	jne mem_alloc_size_if_not_end_block ; pula para a comparacao (next_block - pos - 3) == size, pois esse bloco nao eh o ultimo
	loadn r5, #3
	sub r5, r1, r5 ; block_end_addr - 3
	sub r5, r5, r2 ; (block_end_addr - 3) - pos
	cmp r5, r7
	jne mem_alloc_split ; (block_end_adder - pos - 3) != allocated_size, entao temos que dividir em 2
	jmp mem_alloc_return_current_block ; se tem tamanho igual, retornar esse bloco entao
mem_alloc_size_if_not_end_block:
	loadn r5, #3
	sub r5, r4, r5 ; next_block - 3
	sub r5, r5, r2 ; (next_block - 3) - pos
	cmp r5, r7
	jne mem_alloc_split; (next_block - pos - 3) != allocated_size, entao temos que dividir em 2
mem_alloc_return_current_block:
	loadn r5, #3
	storei r2, r5 ; seta pos[0] = 3, ou seja, nao ta livre
	add r7, r2, r5 ; valor de retorno eh pos + 3
	jmp mem_alloc_return
mem_alloc_split:
	; Temos que inserir um novo bloco em uma lista dinamica duplamente encadeada
	; Atualizando o bloco atual
	loadn r5, #3
	storei r2, r5 ; seta pos[0] = 3, ou seja, nao ta livre
	add r5, r5, r2
	add r5, r5, r7 ; armazena a pos do novo bloco, pos + size + 3
	inc r2
	storei r2, r5 ; seta pos[1] = pos + size + 3, valor do next_block do atual
	dec r2 ; volta r2 ao valor de pos
	; Atualizando o bloco seguinte (next_block), caso nao seja nulo
	cmp r4, r0
	jeq mem_alloc_if_next_block_null_end ; if( next_block == NULL), nao atualizar
	inc r4
	inc r4
	storei r4, r5 ; next_block[2] = pos + size + 3, valor do prev_block do block seguinte
	dec r4
	dec r4 ; voltar r4 ao valor de next_block
mem_alloc_if_next_block_null_end:
	; Inicializando novo bloco
	storei r5, r0 ; pos[size + 3 + 0] = true, novo bloco inicia como free
	inc r5
	storei r5, r4 ; pos[size + 3 + 1] = next_block, o next_block do bloco novo eh o bloco seguinte ao atual
	inc r5
	storei r5, r2 ; pos[size + 3 + 2] = pos, o prev_block do bloco novo eh o bloco atual
	; Determinando valor de retorno
	loadn r5, #3
	add r7, r2, r5 ; pos + 3, o primeiro endereco apos o header do mem_alloc
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

