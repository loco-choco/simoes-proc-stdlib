; Rotinas de alocacao dinamica de memoria

jmp main

block_addr_pos : var #1
block_end_addr_pos : var #10

;---- Inicio do Programa Principal -----
main:
	loadn r7, #1001 ; 4000
	loadn r6, #1011
	call mem_move
	call mem_init
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de 1001 + 3 = 1004
	breakp
	loadn r7, #2
	call mem_alloc
	; esperado r7 ter o valor de (1001 + 3 + 2) + 3 = 1009
	breakp
	loadn r7, #1
	call mem_alloc
	; esperado r7 ter o valor de 0, pois nao ha mais espaco na memoria dinamica
	halt	; Fim do programa - Para o Processador
	
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
	storei r1, r0 ; Seta next_block para NULL
	inc r1
	storei r1, r0 ; Seta prev_block para NULL
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
	jel mem_alloc_search_do_while ; (next_block - pos - 3) < allocated_size
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
	; if( (next_block - pos - 3) == size), o bloco eh perfeito, entao marcar como usado e retornar seu endereco
	loadn r5, #3
	sub r5, r4, r5 ; next_block - 3
	sub r5, r5, r2 ; (next_block - 3) - pos
	cmp r5, r7
	jne mem_alloc_split; (next_block - pos - 3) != allocated_size, temos que quebrar esse bloco em 2
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
