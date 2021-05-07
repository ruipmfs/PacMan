; Projeto Intermédio AC 2020/2021 2º semestre

; Henrique Vaz ist198938
; Rui Pedro Santos ist198966
; Sofia Romeiro ist198968


DISPLAYS   				EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
FATOR_CONV_HEX_DEC      EQU 64H 	; fator utilizado para converter um numero de hexadecimal para decimal

MAX_COUNTER             EQU 100		; valor maximo que o contador pode ter
COUNTER_INIT			EQU 0		; valor inicial do contador

FUNDO_COMECA            EQU 0		; numero do primeiro fundo
EFEITO_SONORO			EQU 0		; numero do primeiro som/video

APAGA_ECRA				EQU 6002H		; endereço do comando que apaga um ecrã
APAGA_AVISO				EQU 6040H		; endereço do comando que apaga o aviso do ecrã
ALTURA_ECRA				EQU 32			; numero de linhas do ecrã
ADICIONAR_FRONTAL		EQU 6046H		; endereço do comando que adiciona um fundo frontal
ADICIONAR_FUNDO			EQU 6042H		; endereço do comando que adiciona um fundo
ADICIONAR_SOM			EQU 6048H		; endereço do comando que adiciona um som/video
PLAY_SOM				EQU 605AH		; endereço do comando que começa um som/video

LINHA_INICIAL_PACMAN	EQU 27			; linha inicial do pacman
COL_INICIAL_PACMAN		EQU 30			; coluna inicial do pacman
LINHA_INICIAL_GHOST		EQU 14			; linha inicial dos fantasmas
COL_INICIAL_GHOST		EQU 31			; coluna inicial dos fantasmas

TECLA_INCREMENTA		EQU 7			; tecla que incrementa o contador
TECLA_DECREMENTA		EQU 3			; tecla que decrementa o contador
TECLA_SOM				EQU 0FH 		; tecla que reproduz o efeito sonoro

DEFINE_LINHA    	EQU 600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   	EQU 600CH      	; endereço do comando para definir a coluna
DEFINE_PIXEL    	EQU 6012H      	; endereço do comando para escrever um pixel

TEC_LIN    			EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    			EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
MASCARA				EQU 0FH 	; para eliminar os bits extra quando se lê o teclado
NAO_HA_TECLA		EQU 0FFFH	; inicializa o valor de saida do teclado quando nao esta a ser clicado (e um valor impossivel)


;***********************************************************************************************************************
; Definição de variáveis
;***********************************************************************************************************************

PLACE 1000H
pilha:	TABLE 100H
SP_inicial:

pos_pacman:			STRING 0, 30					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do pacman (inicializada com a posicao onde o pacman é gerado)
pos_ghost:			STRING 0, 30					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do fantasma em ecra (inicializada com a posicao onde os fantasmas são gerados)
tecla:				WORD NAO_HA_TECLA				; variavel que guarda a tecla a ser premida no momento (inicializada com um valor impossivel)
counter:			WORD COUNTER_INIT				; variavel que guarda o valor do teclado em cada instante (inicializado com o valor inicial do contador)
tecla_anterior:		WORD NAO_HA_TECLA				; ; variavel que guarda a tecla que foi premida anteriormente no teclado

imagem_pacman:	STRING 5,4 				; largura e altura do pacman
				WORD   0FFF0H			; cor do pacman (amarelo)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,0,0
				STRING 1,1,1,1
				STRING 0,1,1,0
				
imagem_ghost: STRING 4,4				; largura e altura do fantasma
				WORD 0FF00H				; cor dos fantasmas (amarelo)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 1,0,0,1


;******************************
; corpo principal do programa
;******************************

PLACE 0
inicio:		
; inicializações
    MOV  SP, SP_inicial			; inicializa SP (stack pointer)
	MOV  R0, APAGA_AVISO
	MOV  [R0], R1				; apaga o aviso do ecra no inicio do jogo
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1				; apaga o ecrã no inicio do jogo
	
	CALL fundo					; mostra o fundo do inicio do jogo
	CALL start					; inicializa todos os elementos do jogo na sua forma inicial

; rotina principal do programa
main:
	CALL p_teclado
	CALL escreve_display
	CALL incrementa_counter
	CALL decrementa_counter
	CALL ativa_efeito_sonoro
	JMP main

;****************************
; PROCESSOS
;****************************
;****************************

; Processo do teclado

; Retorno: Tecla primida em cada instante

; Descrição: procura a cada instante a tecla a ser
; primida no teclado e guarda-a na sua variável

;****************************

p_teclado:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R5
	
    MOV  R1, 8				; começa por procurar se há tecla premida na linha 4 (que corresponde ao numero 8
	MOV  R2, TEC_LIN   		; endereço do periférico das linhas
    MOV  R3, TEC_COL   		; endereço do periférico das colunas
ciclo_espera_tecla:         ; neste ciclo espera-se até uma tecla ser premida
	MOVB [R2], R1     		; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      	    ; ler do periférico de entrada (colunas)
    MOV  R5, MASCARA
    AND  R0, R5        		; elimina os bits 7..4, que estão "no ar" (teclado só liga aos bits 3..0) 
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
	CMP R1, 0
	JNZ ciclo_espera_tecla	; enquanto não estivermos a testar a linha 1, repete a procura
	MOV R2, NAO_HA_TECLA	; se tivermos testado todas então nada está a ser premido (NAO_HA_TECLA tem um valor impossivel para uma tecla)
fim_teclado:
	MOV R0, tecla			
	MOV [R0], R2			; guarda na variavel tecla o valor da tecla premida (se nada tiver sido premido guarda um valor impossivel para não atrapalhar comparações futuras)
	
	POP R5
	POP R3
	POP R2
	POP R1
	POP R0
	RET

;****************************

; Processo de escrita no display

; Retorno: Nenhum

; Descrição: escreve no display o valor do
; contador em cada instante

;****************************

escreve_display:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3

    ; converte o valor de hexadecimal para decimal
    MOV R2, FATOR_CONV_HEX_DEC
    MOV R1, counter
    MOV R1, [R1]
    MOV R0, R1                        ; preserva o valor de R1 (valor atual do counter)
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

;****************************

; Processo de incrementação do contador

; Retorno: valor alterado (ou nao) do contador

; Descrição: verifica se a tecla de incrementação
; está a ser premida e se sim atualiza a variável do
; contador com o novo valor

;****************************

 incrementa_counter:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, counter					
	MOV R0, [R0]
	MOV R1, MAX_COUNTER
	CMP R0, R1							; compara o counter com 100
	JGE fim_incrementa			        ; se for menor que 100, então pode incrementar
	
	
incrementa:
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_INCREMENTA
	CMP R0, R1						; compara a tecla a ser premida no instante com a tecla '7'
	JNZ fim_incrementa				; se não forem iguais, sai da rotina
	
	MOV R1, counter
	MOV R0, [R1]
	CALL time_burner
	ADD R0, 1						; adiciona 1 ao valor atual do counter
	MOV [R1], R0					; guarda o valor incrementado na variavel
	
fim_incrementa:
	POP R2
	POP R1
	POP R0
	RET

;****************************

; Processo de decrementação do contador

; Retorno: valor alterado (ou nao) do contador

; Descrição: verifica se a tecla de decrementação
; está a ser premida e se sim atualiza a variável do
; contador com o novo valor

;****************************

decrementa_counter:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, counter					
	MOV R0, [R0]
	CMP R0, 0					; compara o counter com 0
	JLE fim_decrementa			; se for maior que 0, então pode decrementar
	
	
decrementa:
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_DECREMENTA
	CMP R0, R1						; compara a tecla a ser premida no instante com a tecla '3'
	JNZ fim_decrementa				; se não forem iguais, sai da rotina
	
	MOV R1, counter
	MOV R0, [R1]
	CALL time_burner				; adiciona um 'delay' para que o counter nao incremente muito rapido
	SUB R0, 1						; subtrai 1 ao valor atual do counter
	MOV [R1], R0					; guarda o valor incrementado na variavel
	
fim_decrementa:
	POP R2
	POP R1
	POP R0
	RET

;****************************

; Processo de ativação do efeito sonoro

; Retorno: nenhum

; Descrição: verifica se a tecla do efeito sonoro
; está a ser premida e se sim reproduz o som

;****************************

ativa_efeito_sonoro:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_SOM
	CMP R0, R1						; compara a tecla a ser clicada atualmente com a tecla 'F'
	JNZ fim_sfx						; se nao forem iguais, sai da rotina
									; se forem iguais:
	MOV R1, tecla_anterior			
	MOV R1, [R1]					
	CMP R1, R0						; compara a tecla a ser clicada anteriormente com a atual
	JZ fim_sfx						; se forem iguais, então a tecla está continuamente a ser premida
									; logo, sai da rotina
	CALL som 						; se não, toca o som
	
fim_sfx:
	MOV R1, tecla_anterior
	MOV [R1], R0					; guarda a tecla primida a cada chamada do processo para uso futuro
	POP R2
	POP R1
	POP R0
	RET

;***************************
; ROTINAS AUXILIARES
;***************************
;***************************

; escreve_pixel(linha, coluna, cor)

; Argumentos:
;   - R1: linha
;   - R2: coluna
;   - R3: cor

; Retorno: Nenhum

; Descrição: Altera a cor e transparência
; do pixel presente na linha e coluna recebidas

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
	
;***************************

; desenha_obj(linha, coluna, cor)

; Argumentos:
;   - R1: linha
;   - R2: coluna
;   - R3: objeto

; Retorno: Nenhum

; Descrição: Desenha o objeto recebido começando
; na linha e coluna recebidas com a cor presente
; no próprio objeto

;***************************

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
	
;***************************

; start

; Retorno: nenhum

; Descrição: Inicializa todos os elementos
; do jogo na sua forma inicial

;***************************

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

;*********************************************
; As rotinas que se seguem servem todas para mostrar/reproduzir sons/fundos e seguem todas a mesma lógica
;*********************************************

fundo:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_COMECA
	MOV [R0], R1					; adiciona o fundo inicial ao ecrã
	
	POP R1
	POP R0
	RET

;********************************************

som:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV R0, ADICIONAR_SOM
	MOV R1, PLAY_SOM
	MOV R2, EFEITO_SONORO
	MOV [R0], R2					; adiciona o efeito sonoro ao sistema
	MOV [R1], R2					; reproduz o efeito sonoro
	
	POP R2
	POP R1
	POP R0
	RET

;********************************************

; time_burner

; Retorno: nenhum

; Descrição: Itera uma variável 10000 vezes
; com o objetivo de criar um 'delay' controlado

;********************************************


time_burner:
	PUSH R0
	PUSH R1

	MOV R0, 0
	MOV R1, 10000

ciclo:
	ADD R0, 1			; adiciona 1 ao R0
	CMP R0, R1			; vê se R0 já chegou a 10000
	JNZ ciclo 			; se não, repete o ciclo
						; se sim, sai da rotina
	POP R1
	POP R0
	RET