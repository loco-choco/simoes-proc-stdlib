# String

Essas sao rotinas para lidar com manipulacao e conversao de chars e strings.

Todas elas estao documentadas no proprio arquivo fonte, com um exemplo de uso.
## Rotinas Gerais

### string_lenght

Determina o tamanho da string.

Argumentos:
- r7: string_pointer; endereco da string

Retorno:
- r7: lenght; tamanho da string

## Rotinas String/Char para Inteiro

### convert_char_base_10_to_int

Converte um char para um inteiro em base 10

Argumentos:
- r7: char; caracter a ser convertido

Retorno:
- r7: valor; valor do numero convertido
- r6: codigo de erro:
    - 0 -> convertido
    - 1 -> o char nao eh de inteiro base 10 (0 - 9)

### convert_string_base_10_to_int

Converte uma string para um inteiro em base 10

Argumentos:
- r7: string_pointer; endereco da string

Retorno:
- r7: valor; valor do numero convertido
- r6: codigo de erro:
    - 0 -> convertido
    - 1 -> a string nao eh de inteiro base 10 (0 - 9)
    - 2 -> inteiro muito grande para 16 bits (overflow)

### convert_char_base_16_to_int

Converte um char para um inteiro em base 10

Argumentos:
- r7: char; caracter a ser convertido

Retorno:
- r7: valor; valor do numero convertido
- r6: codigo de erro:
    - 0 -> convertido
    - 1 -> o char nao eh de inteiro base 16 (0 - 9 ou A - F ou a - f)

### convert_string_base_16_to_int

Converte uma string para um inteiro em base 10

Argumentos:
- r7: string_pointer; endereco da string

Retorno:
- r7: valor; valor do numero convertido
- r6: codigo de erro:
    - 0 -> convertido
    - 1 -> a string nao eh de inteiro base 16 (0 - 9 ou A - F ou a - f)
    - 2 -> inteiro muito grande para 16 bits (overflow)

## Rotinas Inteiro para String

### convert_int_to_string_base_16

** A SER IMPLEMENTADO **

Converte uma inteiro para uma string em representacao base 16

Argumentos:
- r7: valor; valor para ser convertido
- r6: string_pointer; endereco da string a ser escrito

Retorno:
Nenhum.

### convert_int_to_string_base_10

** A SER IMPLEMENTADO **

Converte uma inteiro para uma string em representacao base 10

Argumentos:
- r7: valor; valor para ser convertido
- r6: string_pointer; endereco da string a ser escrito

Retorno:
Nenhum.
