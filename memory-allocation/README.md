# Memory Allocation

Essas sao rotinas para lidar com alocacao dinamica no processador do Simoes, pense que é o equivalente a um malloc, mas em assembly.

Todas elas estao documentadas no proprio arquivo fonte, com um exemplo de uso.
## Rotinas

### mem_move

Faz a configuracao do bloco de memoria que deve ser gerenciado pela rotina.

Argumentos:
- r7: block_addr; endereco onde comeca o bloco de memoria
- r6: block_end_addr; endereco onde acaba o bloco de memoria
  
Retorno:
Nenhum.

### mem_init

Inicializa o bloco de memoria.

Argumentos:
Nenhum.

Retorno:
Nenhum.

### mem_alloc

Faz a alocacao dinamica da memoria.

Argumentos:
- r7: allocated_size; tamanho da memoria a ser alocada
  
Retorno:
- r7: memory_pointer; endereco da memoria alocada, caso seu valor seja 0 (NULL) a rotina nao conseguiu alocar a memoria

### mem_free
**A SER IMPLEMENTADA**

Libera a memoria alocada.
Argumentos:
- r7: memory_pointer; endereco da memoria alocada
Retorno:
Nenhum.

### mem_defrager
**A SER IMPLEMENTADA**

Desfragmenta a memoria dinamica.

Argumentos:
Nenhum.

Retorno:
Nenhum.
