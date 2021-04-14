DISPLAYS   				EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)

FATOR_CONV_HEX_DEC      EQU 64H
MAX_COUNTER             EQU 100
FUNDO_COMECA            EQU 0
APAGA_ECRA				EQU 6002H		; endereço do comando que apaga um ecrã
APAGA_AVISO				EQU 6040H		; endereço do comando que apaga o aviso do ecrã
ALTURA_ECRA				EQU 32			; numero de linhas do ecrã
ADICIONAR_FRONTAL		EQU 6046H		; 
APAGAR_FRONTAL			EQU 6044H
ADICIONAR_FUNDO			EQU 6042H		; endereço do comando que adiciona um fundo
LINHA_INICIAL_PACMAN	EQU 27			; linha inicial do pacman
COL_INICIAL_PACMAN		EQU 30			; coluna inicial do pacman
LINHA_INICIAL_GHOST		EQU 14			; linha inicial dos fantasmas
COL_INICIAL_GHOST		EQU 31			; coluna inicial dos fantasmas
TECLA_INCREMENTA		EQU 7
TECLA_DECREMENTA		EQU 3
COUNTER_INIT			EQU 0

TEC_LIN    			EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)

DEFINE_LINHA    	EQU 600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   	EQU 600CH      	; endereço do comando para definir a coluna
DEFINE_PIXEL    	EQU 6012H      	; endereço do comando para escrever um pixel

NAO_HA_TECLA		EQU 0FFFH	; inicializa o valor de saida do teclado quando nao esta a ser clicado (e um valor impossivel)


;***********************************************************************************************************************
PLACE 1000H
pilha:	TABLE 100H
SP_inicial:

pos_pacman:			STRING 0, 30					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do ovni em ecra (inicializada com a posicao onde os ovnis são gerados
pos_ghost:			STRING 0, 30					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do ovni em ecra (inicializada com a posicao onde os ovnis são gerados
tecla:				WORD NAO_HA_TECLA				; variavel que guarda a tecla a ser primida no momento (inicializada com um valor impossivel)
counter:			WORD COUNTER_INIT

imagem_pacman:	STRING 5,4 				; largura e altura da nave
				WORD   0FFF0H			; cor do pacman (amarelo)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 0,1,1,0		; adiciona-se um byte extra no fim de todas as imagens com numero impar de bytes para não perturbar o resto do programa
				
imagem_ghost: STRING 4,4				; largura e altura da explosao
				WORD 0FFF0H			; cor dos fantasmas (verde)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 1,0,0,1


PLACE 0
inicio:		

; inicializações
    MOV  SP, SP_inicial			; inicializa SP (stack pointer)
	MOV  R0, APAGA_AVISO
	MOV  [R0], R1				; apaga o aviso do ecra no inicio do jogo
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1				; apaga o ecrã no inicio do jogo
	
	CALL fundo					; mostra o fundo do inicio do jogo
	CALL start

; corpo principal do programa	
main:							; ciclo principal do jogo
	CALL p_teclado
	CALL escreve_display
	CALL incrementa_counter
	CALL decrementa_counter
	JMP main

;****************************


p_teclado:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	
    MOV  R1, 8				; começa por procurar se há tecla primida na linha 4 (que corresponde ao numero 8
	MOV  R2, TEC_LIN   		; endereço do periférico das linhas
    MOV  R3, TEC_COL   		; endereço do periférico das colunas
ciclo_espera_tecla:         ; neste ciclo espera-se até uma tecla ser premida
	MOVB [R2], R1     		; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      	    ; ler do periférico de entrada (colunas)
    CMP  R0, 0         		; há tecla premida?
	JZ prox_linha			; se não, muda de linha e procura nessa
converte:					; ciclo que converte o valor que recebemos quando clicamos numa tecla no valor dessa mesma tecla
	MOV R2, 0				
converte_linhas:
	SHR R1, 1
	ADD R2, 1
	CMP R1, 0
	JNZ converte_linhas
	SUB R2, 1
	SHL R2, 2 
converte_col:
	SHR R0, 1
	ADD R2, 1
	CMP R0, 0
	JNZ converte_col
	SUB R2, 1
	JMP fim_teclado
prox_linha:					
	SHR R1, 1				; divide a linha atual por 2 para procurar na linha anterior 
	JNZ ciclo_espera_tecla	; enquanto não estivermos a testar a linha 1, repete a procura
	MOV R2, NAO_HA_TECLA	; se tivermos testado todas então nada está a ser primido (NAO_HA_TECLA tem um valor impossivel para uma tecla)
fim_teclado:
	MOV R0, tecla			
	MOV [R0], R2			; guarda na variavel tecla o valor da tecla primida (se nada tiver sido primido guarda um valor impossivel para não atrapalhar comparações futuras)
	
	POP R3
	POP R2
	POP R1
	POP R0
	RET

;***************************

escreve_pixel:
	PUSH R0
	
	MOV  R0, DEFINE_LINHA
    MOV  [R0], R1      			; seleciona a linha
    
    MOV  R0, DEFINE_COLUNA
    MOV  [R0], R2       	    ; seleciona a coluna
    
    MOV  R0, DEFINE_PIXEL
    MOV  [R0], R3         		; altera a cor do pixel na linha e coluna selecionadas
	
	POP R0
	RET
	
;******************************

desenha_obj:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R4, R3
	MOVB R5, [R4]			
	ADD R4, 1				; guarda largura da imagem
	MOVB R6, [R4]
	ADD R4, 1				; guarda altura da imagem
	MOV R3, [R4]
	ADD R4, 2
	MOV R7, R2
	MOV R8, R6

ciclo_linhas:

ciclo_colunas:
	MOVB R9, [R4]
	CMP R9, 0				; compara a string a ser tratada no momento com 0
	JZ  apaga_pixel			; se for 0 apaga esse pixel
	CALL escreve_pixel		; se for 1, pinta esse pixel
	JMP fim_ciclo_col
	
apaga_pixel:
	PUSH R3
	MOV R3, 0				; colocar a cor do pixel a transparente
	CALL escreve_pixel		; e pintá-lo nessa posição
	POP R3
	
fim_ciclo_col:
	ADD R2, 1				; pixel na próxima coluna
	ADD R4, 1
	SUB R6, 1				; decrementa largura
	JNZ ciclo_colunas		; se chegar a 0
	
	ADD R1, 1				; então, pixel na próxima linha
	MOV R2, ALTURA_ECRA
	CMP R1, R2				; se a linha que estamos a pintar for inexistente (32 não é uma linha)
	JZ  fim_desenha_obj		; então sai da rotina
	MOV R2, R7				; repõe os valores
	MOV R6, R8				; repõe os valores
	SUB R5, 1				; decrementa altura
	JNZ	ciclo_linhas		; se não for 0, repete o ciclo

fim_desenha_obj:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	RET
	
;********************************************

start:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV R0, counter
    MOV R1, COUNTER_INIT
    MOV [R0], R1                        ; repõe counter a 0
    CALL escreve_display                ; escreve-o no display
	
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1						; apaga os pixeis no ecrã
	
	MOV R1, LINHA_INICIAL_PACMAN
	MOV R2, COL_INICIAL_PACMAN
	MOV R3, imagem_pacman
	CALL desenha_obj					; desenha pacmman na sua posição inicial
	MOV R0, pos_pacman
	MOV [R0], R2						; repõe posição inicial do pacman
	
	MOV R1, LINHA_INICIAL_GHOST
	MOV R2, COL_INICIAL_GHOST
	MOV R3, imagem_ghost
	CALL desenha_obj 					; desenha fantasma na sua posição inicial
	MOV R0, pos_ghost
	MOV [R0], R2						; repõe posição inicial do fantasma
	
	POP R3
	POP R2
	POP R1
	POP R0
	RET

;********************************************

incrementa_counter:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, counter					
	MOV R0, [R0]
	MOV R1, MAX_COUNTER
	CMP R0, R1						; compara o counter com 100
	JLT incrementa			        ; se for menor que 100, então pode incrementar
	
	
incrementa:
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_INCREMENTA
	CMP R0, R1						; compara a tecla a ser primida no instante com a tecla '7'
	JNZ fim_incrementa				; se não forem iguais, sai da rotina
	
	MOV R0, counter
	MOV R0, [R0]
	ADD R0, 1
	MOV [R0], R0
	
fim_incrementa:
	POP R2
	POP R1
	POP R0
	RET
;********************************************

decrementa_counter:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, counter					
	MOV R0, [R0]
	CMP R0, 0				; compara o counter com 0
	JGT decrementa			; se for maior que 0, então pode decrementar
	
	
decrementa:
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_DECREMENTA
	CMP R0, R1						; compara a tecla a ser primida no instante com a tecla '3'
	JNZ fim_decrementa				; se não forem iguais, sai da rotina
	
	MOV R0, counter
	MOV R0, [R0]
	SUB R0, 1
	MOV [R0], R0
	
fim_decrementa:
	POP R2
	POP R1
	POP R0
	RET


;********************************************
fundo:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_COMECA
	MOV [R0], R1
	
	POP R1
	POP R0
	RET

;********************************************************
escreve_display:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3

    ; converte o valor de hexadecimal para decimal
    MOV R2, FATOR_CONV_HEX_DEC
    MOV R0, R1                        ; preserva o valor de R1 (energia atual da nave)
    DIV R0, R2 
    MOD R1, R2
    SHL R0, 4
    MOV R2, 10
    MOV R3, R1
    DIV R1, R2
    OR  R0, R1
    SHL R0, 4
    MOD R3, R2
    OR  R0, R3

    MOV R1, DISPLAYS
    MOV [R1], R0                      ; escreve o valor convertido no display

    POP R3
    POP R2
    POP R1
    POP R0
    RET