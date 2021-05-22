; Projeto Intermédio AC 2020/2021 2º semestre

; Henrique Vaz ist198938
; Rui Pedro Santos ist198966
; Sofia Romeiro ist198968


DISPLAYS   				EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
FATOR_CONV_HEX_DEC      EQU 64H 	; fator utilizado para converter um numero de hexadecimal para decimal

COUNTER_INIT			EQU 0		; valor inicial do contador

FUNDO_COMECO			EQU 0			; numero do fundo no Mediacenter
FUNDO_JOGO	        	EQU 1			; numero do fundo no Mediacenter
FRONTAL_PAUSA			EQU 2			; numero do fundo no MediaCenter
FUNDO_DERROTA			EQU 3			; numero do fundo no MediaCenter
FUNDO_VITORIA			EQU 4			; numero do fundo no MediaCenter
FUNDO_FIM				EQU 5			; numero do fundo no MediaCenter

APAGA_ECRA				EQU 6002H		; endereço do comando que apaga um ecrã
APAGA_AVISO				EQU 6040H		; endereço do comando que apaga o aviso do ecrã
ALTURA_ECRA				EQU 32			; numero de linhas do ecrã
ADICIONAR_FRONTAL		EQU 6046H		; endereço do comando que adiciona um fundo frontal
APAGAR_FRONTAL			EQU 6044H		; endereço do comando que apaga um fundo frontal
ADICIONAR_FUNDO			EQU 6042H		; endereço do comando que adiciona um fundo
APAGA_FUNDO				EQU 6040H		; endereço do comando que apaga um fundo

LINHA_INICIAL_PACMAN	EQU 23			; linha inicial do pacman
COL_INICIAL_PACMAN		EQU 30			; coluna inicial do pacman
LINHA_INICIAL_GHOST		EQU 3			; linha inicial dos fantasmas
COL_INICIAL_GHOST		EQU 31			; coluna inicial dos fantasmas
LIN_X_CIM				EQU 1			; linha dos X's de cima
LIN_X_BAIX				EQU 27			; linha dos X's de baixo
COL_X_ESQ				EQU 1			; coluna dos X's da esquerda
COL_X_DIR				EQU 59			; coluna dos X's da direita

TECLA_CIMA				EQU 1			; tecla de andar para cima
TECLA_BAIXO				EQU 9			; tecla de andar para baixo
TECLA_ESQ				EQU 4			; tecla de andar para a esquerda
TECLA_DIR				EQU 6			; tecla de andar para a direita
TECLA_CE				EQU 0			; tecla de andar para a diagonal cima esquerda
TECLA_CD				EQU 2			; tecla de andar para a diagonal cima direita
TECLA_BE				EQU 8			; tecla de andar para a diagonal baixo esquerda
TECLA_BD				EQU 0AH			; tecla de andar para a diagonal baixo direita
TECLA_START_RESET		EQU 0CH			; tecla de comecar e recomecar
TECLA_PAUSE				EQU 0DH			; tecla de suspender e retomar o jogo
TECLA_END				EQU 0EH			; tecla de terminar o jogo

LIM_ESQ					EQU 0			; limite esquerdo do ecra
LIM_DIR					EQU 60			; limite direito do ecra
LIM_CIM					EQU 0			; limite de cima do ecra
LIM_BAIX				EQU 27			; limite de baixo do ecra
LIM_CIM_C				EQU 20			; limite de baixo da caixa
LIM_BAIX_C				EQU 7			; limite de cima da caixa
LIM_ESQ_C				EQU 40			; limite direito da caixa
LIM_DIR_C				EQU 24			; limite esquerdo da caixa
LIM_DIR_X				EQU 55			; limite esquerdo dos X's
LIM_ESQ_X				EQU 5			; limite direito dos X's
LIM_CIM_X				EQU 22			; limite de baixo dos X's
LIM_BAIX_X				EQU 5			; limite de cima dos X's

DEFINE_LINHA    		EQU 600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      	; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      	; endereço do comando para escrever um pixel

TEC_LIN    				EQU 0C000H		; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    				EQU 0E000H		; endereço das colunas do teclado (periférico PIN)
MASCARA					EQU 0FH 		; para eliminar os bits extra quando se lê o teclado
NAO_HA_TECLA			EQU 0FFFH		; inicializa o valor de saida do teclado quando nao esta a ser clicado (e um valor impossivel)

VERIFICA_PARIDADE		EQU 2			; numero utilizado para fazer o resto da divisão aquando da necessidade de determinar a paridade de algo


;***********************************************************************************************************************
; Definição de variáveis
;***********************************************************************************************************************

PLACE 1000H
pilha:	TABLE 100H
SP_inicial:
      
tab:	WORD rot_int_0      ; rotina de atendimento da interrupção 0
    	WORD rot_int_1      ; rotina de atendimento da interrupção 1
    	WORD rot_int_2      ; rotina de atendimento da interrupção 2

tab_eventos_interr:
    WORD 0
    WORD 0
    WORD 0

pausa:				WORD 0							; variavel que guarda a flag da pausa ou nao pausa do jogo
parado:  			WORD 1							; variavel que guarda a flag que diz se o jogo esta parado ou nao
pos_pacman:			STRING 23, 30					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do pacman (inicializada com a posicao onde o pacman é gerado)
pos_ghost:			STRING 3, 31					; variavel que guarda a posicao (linha e coluna por esta ordem) atual do fantasma em ecra (inicializada com a posicao onde os fantasmas são gerados)
tecla:				WORD NAO_HA_TECLA				; variavel que guarda a tecla a ser premida no momento (inicializada com um valor impossivel)
counter:			WORD COUNTER_INIT				; variavel que guarda o valor do tempo de jogo em cada instante (inicializado com 0)
xs_apagados:		STRING 0,0,0,0,0,0				; variavel que guarda a flag que verifica se cada X ja foi apanhado ou nao
pausar_ou_continuar:WORD 0							; variavel que guarda um valor que decide se o próximo clique na pausa faz pausa ou retoma o jogo


imagem_pacman:	STRING 5,4 				; largura e altura do pacman
				WORD   0FFF0H			; cor do pacman (amarelo)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 0,1,1,0
				
imagem_pacman_aberto_d:	STRING 5,4 				; largura e altura do pacman
						WORD   0FFF0H			; cor do pacman (amarelo)
						STRING 0,1,1,0			; imagem (boca aberta direita)
						STRING 1,1,1,1
						STRING 1,0,0,0
						STRING 1,1,1,1
						STRING 0,1,1,0
						
imagem_pacman_aberto_c:	STRING 5,4 				; largura e altura do pacman
						WORD   0FFF0H			; cor do pacman (amarelo)
						STRING 1,0,0,1			; imagem (boca aberta cima)
						STRING 1,0,0,1
						STRING 1,0,0,1
						STRING 1,1,1,1
						STRING 0,1,1,0						
				
imagem_ghost: STRING 4,4				; largura e altura do fantasma
				WORD 0FF00H				; cor dos fantasmas (amarelo)
				STRING 0,1,1,0			; imagem
				STRING 1,1,1,1
				STRING 1,1,1,1
				STRING 1,0,0,1
				
imagem_x: STRING 4,4					; largura e altura do X
			WORD 0F0F0H					; cor dos fantasmas (vermelho)
			STRING 1,0,0,1				; imagem
			STRING 0,1,1,0
			STRING 0,1,1,0
			STRING 1,0,0,1
			
imagem_explosao: STRING 5,5				; largura e altura da explosao
					WORD 0F0FFH			; cor da explosao (azul)
					STRING 0,1,0,1,0	; imagem
					STRING 1,0,1,0,1
					STRING 0,1,0,1,0
					STRING 1,0,1,0,1
					STRING 0,1,0,1,0,0	; adiciona-se um 0 para se ficar com um numero par
										; para nao perturbar o resto do programa

;******************************
; corpo principal do programa
;******************************

PLACE 0
inicio:		
; inicializações
	MOV  BTE, tab
    MOV  SP, SP_inicial			; inicializa SP (stack pointer)
	MOV  R0, APAGA_AVISO
	MOV  [R0], R1				; apaga o aviso do ecra no inicio do jogo
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1				; apaga o ecrã no inicio do jogo
	
	CALL fundo_comeca			; adiciona o fundo inicial ao ecra

	EI0                      	; permite interrupções 0
    EI1                   	    ; permite interrupções 1
    EI2                     	; permite interrupções 2
    EI                       	; permite interrupções (geral)

; rotina principal do programa
main:
	CALL p_teclado
	CALL p_controlo
	CALL p_display
	CALL p_incrementa_tempo
	CALL p_pacman
	CALL p_fantasmas
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
;*********************************************************************************
p_controlo:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	
	CALL vitoria					; chama a funcao que atualiza a variavel que guarda os X's que foram apanhados
	CMP R3, 4						; os 4 X's ja foram apanhados?
	JNZ continua_a_correr			; se não passa para a proxima verificacao
									
	MOV R0, parado				
	MOV R1, 1						; se sim, ativa a flag do jogo parado
	MOV [R0], R1					; e atualiza-a na variável parado
	
	CALL fundo_vitoria				; e adiciona o fundo da vitoria ao ecra
	
continua_a_correr:
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_START_RESET
	CMP R0, R1						; compara a tecla a ser primida no instante com a tecla 'C'
	JNZ verifica_termina			; se não forem iguais, verifica a próxima condição
	
	CALL start						; começa (ou recomeça) o jogo
	JMP fim_controlo
	
verifica_termina:
	MOV R1, TECLA_END				
	CMP R0, R1						; compara a tecla a ser primida no instante com a tecla 'E'
	JNZ verifica_pausa				; se não forem iguais, verifica a próxima condição
	
	CALL apaga_fundo				; apaga o fundo do jogo
	CALL fundo_fim					; ativa o fundo do final do jogo
	
	MOV R0, parado
	MOV R1, 1						; ativa a flag do jogo parado
	MOV [R0], R1					; e atualiza-a na variável parado
	
	JMP fim_controlo
	
verifica_pausa:
	MOV R1, TECLA_PAUSE				
	CMP R0, R1						; compara a tecla a ser primida no instante com a tecla 'D'
	JNZ fim_controlo				; se não forem iguais, sai do processo

	MOV R1, tecla
	MOV R2, NAO_HA_TECLA			; guarda o valor impossivel para uma tecla na variavel tecla
	MOV [R1], R2
	
	MOV R0, pausa
	MOV R1, [R0]
	MOV R2, 1
	XOR R1, R2
	MOV [R0], R1					; ativa e desativa a flag da pausa consoante se vai clicando na tecla 'D'
	
	MOV R3, pausar_ou_continuar		
	MOV R3, [R3]
	ADD R3, 1						; incrementa um contador que armazena quantas vezes a tecla 'D' foi clicada
	MOV R0, VERIFICA_PARIDADE
	MOD R3, R0
	MOV R0, pausar_ou_continuar
	MOV [R0], R3					; guarda na variável pausar_ou_continuar um valor que define se o próximo clique origina uma pausa ou uma retoma (0 -> retoma | 1 -> pausa)
	CMP R3, 0						; é par?
	JZ  mudancas_ecra_retoma		; se sim, é uma retoma
									; se não, é uma pausa
mudancas_ecra_pausa:
	CALL cenario_frontal_pausa		; mostra a imagem da pausa

	JMP fim_controlo
	
mudancas_ecra_retoma:
	CALL apaga_frontal_pausa		; apaga a imagem da pausa
	
fim_controlo:
	POP R3
	POP R2
	POP R1
	POP R0
	RET
;*********************************************************************************
p_display:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3

    ; converte o valor de hexadecimal para decimal
    MOV R2, FATOR_CONV_HEX_DEC
    MOV R1, counter
    MOV R1, [R1]						; guarda em R1 o valor atua do counter
    MOV R0, R1                    	    ; preserva em R0 o valor de R1 (valor atual do counter)
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
	
;*********************************************************************************
p_incrementa_tempo:
	PUSH R0
	PUSH R1
	
	MOV R0, pausa		
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está em pausa
	JNZ fim_tempo		    		; se estiver, não executa o processo
	
	MOV R0, parado					
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está parado
	JNZ fim_tempo    				; se estiver, não executa o processo
	
	MOV R0, tab_eventos_interr
	ADD R0, 2
	MOV R1, [R0]
	CMP R1, 0						; verifica se há interrupção
	JZ  fim_tempo					; se não houver não aumenta o tempo de jogo
	MOV R1, 0
	MOV [R0], R1					; se houver repõe a flag da rotina de intrrupção
	
	MOV R0, counter
	MOV R1, [R0]					; guarda o valor atual do counter em R1
	ADD R1, 1						; incrementa esse valor em 1 unidade
	MOV [R0], R1					; e atualiza de novo a variavel counter
	
fim_tempo:
	POP R1
	POP R0
	RET

;*********************************************************************************
p_pacman:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R0, pausa		
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está em pausa
	JNZ fim_pacman					; se estiver, não executa o processo
	
	MOV R0, parado					
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está parado
	JNZ fim_pacman    				; se estiver, não executa o processo
	
	MOV R0, tecla
	MOV R0, [R0]
	MOV R1, TECLA_CIMA
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 1
	JNZ  b_							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_CIM					; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_CIM_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, -1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman
b_:
	MOV R1, TECLA_BAIXO
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 9
	JNZ d_							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_BAIX				; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_BAIX_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, 1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman
d_:
	MOV R1, TECLA_DIR
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 6
	JNZ e_							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_DIR					; se for, guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_DIR_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, 1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman
e_:
	MOV R1, TECLA_ESQ
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 4
	JNZ cd							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_ESQ					; se for, guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_ESQ_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, -1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman

cd:
	MOV R1, TECLA_CD
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 2
	JNZ ce							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_CIM					; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_CIM_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, -1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	MOV R5, LIM_DIR					; guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_DIR_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, 1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman			
ce:
	MOV R1, TECLA_CE
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 0
	JNZ be							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_CIM					; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_CIM_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, -1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	MOV R5, LIM_ESQ					; guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_ESQ_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, -1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman					

be:
	MOV R1, TECLA_BE
	CMP R0, R1						; vê se a tecla a ser primida no momento é a 8
	JNZ bd							; se nao for, testa a proxima tecla de movimento
	MOV R5, LIM_BAIX				; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_BAIX_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, 1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	MOV R5, LIM_ESQ					; guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_ESQ_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, -1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	JMP colisoes_objetos_pacman		
bd:
	MOV R1, TECLA_BD
	CMP R0, R1						; vê se a tecla a ser primida no momento é a A
	JNZ colisoes_objetos_pacman		; se nao for, testa colisoes do pacman com outros objetos
	MOV R5, LIM_BAIX				; se for, guarda as variaveis de limites nos registos que a rotina move_c_b recebe
	MOV R6,	LIM_BAIX_C
	MOV R7,	LIM_DIR_C
	MOV R8,	LIM_ESQ_C
	MOV R9, 1
	CALL move_c_b					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman
	MOV R5, LIM_DIR					; guarda as variaveis de limites nos registos que a rotina move_d_e recebe
	MOV R6,	LIM_DIR_C
	MOV R7,	LIM_CIM_C
	MOV R8,	LIM_BAIX_C
	MOV R9, 1
	CALL move_d_e					; rotina que testa se o pacman nao colide com paredes e move (ou nao) o pacman

colisoes_objetos_pacman:
	CALL verifica_colisoes			; rotina que testa colisoes do pacman com outros objetos

fim_pacman:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
;*******************************
p_fantasmas:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10
	
	MOV R0, pausa		
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está em pausa
	JNZ fim_fantasma		    	; se estiver, não executa o processo
	
	MOV R0, parado					
	MOV R0, [R0]
	CMP R0, 0						; vê se o jogo está parado
	JNZ fim_fantasma    			; se estiver, não executa o processo
	
	MOV R0, pos_ghost
	MOVB R1, [R0]
	ADD R0, 1
	MOVB R2, [R0]					; obtém as componentes da posição atual do fantasma
	
	MOV R3, tab_eventos_interr
	MOV R4, [R3]
	CMP R4, 0						; verifica se há interrupção
	JZ  fim_fantasma				; se não houver, sai do processo
	MOV R4, 0
	MOV [R3], R4					; se houver repõe a flag da rotina de intrrupção
	
	MOV R3, imagem_ghost			
	
	CALL apaga_obj					; apaga o fantasma da posição atual
	
	MOV R4, pos_pacman
	MOVB R5, [R4]
	ADD R4, 1
	MOVB R6, [R4]					; obtem as componentes da posicao atual do pacman
	
	CMP R5, R1						; compara a linha do pacman com a linha do fantasma
	JGT move_fantasma_baixo			; se o pacman estiver "abaixo" do fantasma entao salta para a label onde se move o fantasma para baixo; se nao, testa se pode mover para cima
	MOV R7, 20						; 20 é linha antes da caixa
	MOV R8, 25						; 25 é coluna da caixa -4(largura do fantasma)
	MOV R9, 39						; 39 é coluna da caixa
	CALL testa_colisao_caixa_vert	; rotina que testa se o fantasma colide verticalmente com a caixa (R10 = 1 -> colide | R10 = 0 -> nao colide)
	CMP R10, 1						
	JZ move_fantasma_hori			; se colidir testa o movimento horizontal
	SUB R1, 1						; se nao, move o fantasma para cima
	JMP move_fantasma_hori			; e testa horizontal de seguida
move_fantasma_baixo:
	MOV R7, 8						; 8 é linha antes da caixa-4(altura do fantasma)
	MOV R8, 25						; 25 é coluna da caixa -4(largura do fantasma)
	MOV R9, 39						; 39 é coluna da caixa
	CALL testa_colisao_caixa_vert	; rotina que testa se o fantasma colide verticalmente com a caixa (R10 = 1 -> colide | R10 = 0 -> nao colide)
	CMP R10, 1
	JZ move_fantasma_hori			; se colidir testa o movimento horizontal
	ADD R1, 1						; se nao, move o fantasma para baixo 
									; e testa o movimento horizontal
move_fantasma_hori:	
	CMP R6, R2						; compara a coluna do pacman com a coluna do fantasma
	JGT move_fantasma_dir			; se o pacman estiver "à direita" do fantasma entao salta para a label onde se move o fantasma para a direita; se nao, testa se pode mover para a esquerda
	MOV R7, 40						; 40 é coluna antes da caixa
	MOV R8, 8						; 8 é linha da caixa -4(altura do fantasma)
	MOV R9, 20						; 20 é linha da caixa
	CALL testa_colisao_caixa_horiz	; rotina que testa se o fantasma colide horizontalmente com a caixa (R10 = 1 -> colide | R10 = 0 -> nao colide)
	CMP R10, 1				
	JZ next_ghost					; se colidir atualiza a posicao do fantasma
	SUB R2, 1						; se nao, move o fantasma para a esquerda	
	JMP next_ghost					; e atualiza a posicao do fantasma
move_fantasma_dir:
	MOV R7, 24						; 24 é coluna antes da caixa-4(altura do fantasma)
	MOV R8, 8						; 8 é linha da caixa -4(altura do fantasma)
	MOV R9, 20						; 20 é linha da caixa
	CALL testa_colisao_caixa_horiz  ; rotina que testa se o fantasma colide horizontalmente com a caixa (R10 = 1 -> colide | R10 = 0 -> nao colide)
	CMP R10, 1
	JZ next_ghost					; se colidir atualiza a posicao do fantasma
	ADD R2, 1						; se nao, move o fantasma para a esquerda
									; e atualiza a posicao do fantasma
next_ghost:
	MOV R0, pos_ghost
	MOVB [R0], R1
	ADD R0, 1
	MOVB [R0], R2					; atualiza a variável da posição do ovni 
	
	CALL desenha_obj				; desenha o ovni na sua posição atualizada

fim_fantasma:
	POP R10
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
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
apaga_obj:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	
	MOV R4, R3
	MOVB R5, [R4]
	ADD R4, 1
	MOVB R6, [R4]
	MOV R3, 0					; cor transparente
	MOV R7, R2
	MOV R8, R6

ciclo_linhas_a:

ciclo_colunas_a:				; faz o mesmo que o desenha_obj mas
	CALL escreve_pixel			; pinta sempre o pixel a transparente
	ADD R2, 1
	SUB R6, 1
	JNZ ciclo_colunas_a
	
	ADD R1, 1
	MOV R2, ALTURA_ECRA
	CMP R1, R2
	JZ  fim_apaga_obj
	MOV R2, R7
	MOV R6, R8
	SUB R5, 1
	JNZ	ciclo_linhas_a

fim_apaga_obj:	
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
	
	CALL fundo

	MOV R0, counter
    MOV R1, COUNTER_INIT
    MOV [R0], R1                        ; repõe counter a 0
    CALL p_display                		; escreve-o no display
	
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1						; apaga os pixeis no ecrã
	
	MOV R1, LINHA_INICIAL_PACMAN
	MOV R2, COL_INICIAL_PACMAN
	MOV R3, imagem_pacman
	CALL desenha_obj					; desenha pacmman na sua posição inicial
	MOV R0, pos_pacman
	MOVB [R0], R1						; repõe posição inicial do pacman
	ADD R0, 1
	MOVB [R0], R2
	
	MOV R1, LINHA_INICIAL_GHOST
	MOV R2, COL_INICIAL_GHOST
	MOV R3, imagem_ghost
	CALL desenha_obj 					; desenha fantasma na sua posição inicial
	MOV R0, pos_ghost
	MOVB [R0], R1						; repõe posição inicial do fantasma
	ADD R0, 1
	MOVB [R0], R2
	
	MOV R3, imagem_x					
										; desenha todos os X´s nas suas posicoes iniciais
	MOV R1, LIN_X_CIM
	MOV R2, COL_X_ESQ
	CALL desenha_obj
	
	MOV R1, LIN_X_CIM
	MOV R2, COL_X_DIR
	CALL desenha_obj
	
	MOV R1, LIN_X_BAIX
	MOV R2, COL_X_ESQ
	CALL desenha_obj
	
	MOV R1,	LIN_X_BAIX
	MOV R2, COL_X_DIR
	CALL desenha_obj
	
	MOV R0, parado
	MOV R1, [R0]
	MOV R1, 0
	MOV [R0], R1						; desativa a flag parado
	
	MOV R0, pausa
	MOV R1, [R0]
	MOV R1, 0
	MOV [R0], R1						; desativa a flag pausa
	
	POP R3
	POP R2
	POP R1
	POP R0
	RET
;**************************************************************
verifica_colisoes:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R0, pos_pacman
	MOVB R1, [R0]
	ADD R0, 1
	MOVB R2, [R0]				; guarda a posição do pacman em ecrã
	MOV R0, imagem_pacman
	MOVB R3, [R0]
	ADD R3, R1					; limite de baixo do pacman
	ADD R0, 1
	MOVB R4, [R0]
	ADD R4, R2					; limite da direita do pacman
	
	MOV R5, LIM_BAIX_X			; limites de onde estao os X's
	MOV R6, LIM_DIR_X
	MOV R7, LIM_CIM_X
	MOV R8, LIM_ESQ_X
	
	CMP R1, R7					
	JGT cima_baixo				; se o pacman estiver a baixo do topo dos X's de baixo verifica se esta a colidir com algum
								; se nao, verifica a proxima comparacao
	CMP R3, R5					
	JLT cima_baixo				; se o pacman estiver a cima da parte de baixo dos X's de cima verifica se esta a colidir com algum				
								; se nao, verifica a proxima comparacao
	CMP R2, R8					
	JLT esq_dir					; se o pacman estiver a esquerda da direita dos X's da esquerda verifica se esta a colidir com algum
								; se nao, verifica a proxima comparacao
	CMP R4, R6						
	JGT esq_dir					; se o pacman estiver a direita da esquerda dos X's da direita verifica se esta a colidir com algum
								; se nao, verifica a colisao com fantasmas
	JMP verifica_ghost
	
cima_baixo:
	CMP R2, R8					
	JGT next_cb					; se o pacman estiver a direita da direita dos X's da esquerda testa o proximo lado	
								; se nao, entao eh o X do lado esquerdo
	CALL linha_mais_prox		; ve qual eh a linha mais proxima para decidir se é do canto superior ou inferior (guarda em R6)
	MOV R5, 1					; guarda em R5 a coluna 1 (coluna dos X's da esquerda)
	CALL apaga_xs				; apaga o X
	
	MOV R5, xs_apagados			
	CMP R6, 1					; vê se eh o X do canto sup esquerdo ou canto inf esquerdo
	JZ  cse						; se for o do canto superior esquerdo ativa a flag que diz se esse X ja foi apanhado
	ADD R5, 2					; se nao ativa a flag que diz se o X do canto inferior esquerdo ja foi apanhado
cse:
	MOV R9, 1
	MOVB [R5], R9

	JMP fim_colisoes

;os comentarios dos proximos 3 blocos de 18 linhas sao semelhantes aos das 18 linhas anteriores	
next_cb:
	CMP R4, R6
	JLT verifica_ghost			
	
	CALL linha_mais_prox
	MOV R5, 59
	CALL apaga_xs
	
	MOV R5, xs_apagados
	CMP R6, 1
	JZ csd
	ADD R5, 2
csd:
	ADD R5, 1
	MOV R9, 1
	MOVB [R5], R9

	JMP fim_colisoes
	
esq_dir:
	CMP R1, R7
	JLT next_ed					; se o pacman estiver a esquerda da esquerda dos X's da direita testa o proximo lado 
								; se nao, entao eh o X do lado direito
	MOV R6, 1					; guarda em R6 a linha 1 (linha dos X's de cima)
	CALL coluna_mais_prox		; ve qual eh a coluna mais proxima para decidir se são os cantos da esquerda ou da direita (guarda em R6)
	CALL apaga_xs				; apaga o X
	
	MOV R6, xs_apagados			
	CMP R5, 1					; vê se eh o X do canto sup direito ou canto inf direito
	JZ csupe					; se for o do canto superior esquerdo ativa a flag que diz se esse X ja foi apanhado
	ADD R6, 1					; se nao ativa a flag que diz se o X do canto inferior???? esquerdo ja foi apanhado
csupe:
	MOV R9, 1
	MOVB [R6], R9
	
	JMP fim_colisoes

next_ed:
	CMP R3, R5
	JGT verifica_ghost
	
	MOV R6, 27
	CALL coluna_mais_prox
	CALL apaga_xs
	
	MOV R6, xs_apagados
	CMP R5, 1
	JZ cinfe
	ADD R6, 1
cinfe:
	ADD R6, 2
	MOV R9, 1
	MOVB [R6], R9
	
	JMP fim_colisoes
	
verifica_ghost:
	MOV R0, pos_ghost			
	MOVB R5, [R0]
	ADD R0, 1
	MOVB R6, [R0]				; guarda as componentes da posicao do fantasma		
	MOV R0, imagem_ghost
	MOVB R7, [R0]
	ADD R7, R5					; linha de baixo do fantasma
	ADD R0, 1
	MOVB R8, [R0]
	ADD R8, R6					; coluna da direita do fantasma
	
	MOV R0, 0
	
	CMP R1, R7					; todos estes CMP vêm se o pacman colide com o fantasma, se não, sai da rotina
	JGT fim_colisoes
	
	CMP R3, R5
	JLE fim_colisoes
	
	CMP R2, R8
	JGE fim_colisoes
	
	CMP R4, R6
	JLE fim_colisoes
	
	MOV R3, imagem_explosao		
	CALL desenha_obj			; se sim desenha a explosao
	; TODO: rotina nova interrupcao explosao
	MOV R0, parado
	MOV R1, 1					
	MOV [R0], R1				; ativa a flag do jogo parado
	MOV  R0, APAGA_ECRA
	MOV  [R0], R1				; apaga os pixeis no ecrã
	CALL apaga_fundo			; apaga o fundo do jogo
	CALL fundo_derrota			; mostra-se o fundo de quando se perde
	
fim_colisoes:
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET



;*********************************************
; As rotinas que se seguem servem todas para mostrar/apagar fundos e seguem todas a mesma lógica
;*********************************************
fundo_comeca:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_COMECO
	MOV [R0], R1 					; adiciona o fundo do começo de jogo ao ecrâ
	
	POP R1
	POP R0
	RET

;**********************************************
fundo:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_JOGO
	MOV [R0], R1					; adiciona o fundo inicial ao ecrã
	
	POP R1
	POP R0
	RET
	
;*********************************************
apaga_fundo:
	PUSH R0
	PUSH R1
	
	MOV R0, APAGA_FUNDO
	MOV R1, FUNDO_JOGO
	MOV [R0], R1 					; apaga o fundo inicial ao ecrâ 
	
	POP R1
	POP R0
	RET

;*******************************************************
cenario_frontal_pausa:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FRONTAL
	MOV R1, FRONTAL_PAUSA
	MOV [R0], R1   					
	
	POP R1
	POP R0
	RET

;*******************************************************	
apaga_frontal_pausa:
	PUSH R0
	PUSH R1
	
	MOV R0, APAGAR_FRONTAL
	MOV R1, FRONTAL_PAUSA
	MOV [R0], R1 					
	
	POP R1
	POP R0
	RET
	
;*********************************************************
fundo_derrota:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_DERROTA
	MOV [R0], R1 					; adiciona o fundo de derrota ao ecrâ	
	
	POP R1
	POP R0
	RET

;*******************************************************
fundo_vitoria:
	PUSH R0
	PUSH R1
	
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_VITORIA
	MOV [R0], R1    				; adiciona o fundo de vitória ao ecrâ
	
	POP R1
	POP R0
	RET

;*******************************************************
fundo_fim:
	PUSH R0
	PUSH R1
	
	MOV R0, APAGA_ECRA
	MOV [R0], R1       				; apaga o fundo que está atualmente no ecrâ
	MOV R0, ADICIONAR_FUNDO
	MOV R1, FUNDO_FIM
	MOV [R0], R1  					; adiciona o fundo do fim ao ecrâ
	
	POP R1
	POP R0
	RET	
	
;*********************************************************



;*********************************************

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
	
	
;************************************************
apaga_xs:
	PUSH R1
	PUSH R2
	PUSH R3
	
	MOV R1, R6
	MOV R2, R5
	MOV R3, imagem_x
	CALL apaga_obj
	
	POP R3
	POP R2
	POP R1
	RET
	
;**********************************************
linha_mais_prox:
	PUSH R1
	PUSH R2

	MOV R2, 23
	CMP R1, R2
	JGE em_baixo
	MOV R6, 1
	
em_baixo:
	MOV R6, 27
	
	POP R2
	POP R1
	RET
	
;********************************************

coluna_mais_prox:
	PUSH R1
	PUSH R2

	MOV R2, 56
	CMP R1, R2
	JGE a_esq
	MOV R5, 1
	
a_esq:
	MOV R5, 59
	
	POP R2
	POP R1
	RET
	
;************************************************

vitoria:
	PUSH R1
	PUSH R2

	MOV R1, xs_apagados
	MOV R3, 0
vitoria_aux:
	MOV R2, [R1]
	CMP R2, 1
	JZ rec
	JMP fim_vitoria
rec:
	ADD R3, 1
	ADD R1,1
	JMP vitoria_aux
	

fim_vitoria:	
	POP R2
	POP R1
	RET
;****************************************************

	
;****************************************************


	
;*********************************************
testa_colisao_caixa_vert:
	PUSH R1
	PUSH R2
	PUSH R7
	PUSH R8
	PUSH R9
	
	CMP R1, R7
	JZ testa_coluna
	JMP nao_colide
testa_coluna:
	CMP R2, R8
	JGE testa_col_fim
	JMP fim_testa_coli
testa_col_fim:
	CMP R2, R9
	JGT nao_colide
	MOV R10, 1
	JMP fim_testa_coli
nao_colide:
	MOV R10, 0
	
fim_testa_coli:
	POP R9
	POP R8
	POP R7
	POP R2
	POP R1
	RET
	
testa_colisao_caixa_horiz:
	PUSH R1
	PUSH R2
	PUSH R7
	PUSH R8
	PUSH R9
	
	CMP R2, R7
	JZ testa_linha
	JMP nao_colidiu
testa_linha:
	CMP R1, R8
	JGT testa_coli_fim
	JMP fim_testa_coli_h
testa_coli_fim:
	CMP R1, R9
	JGT nao_colidiu
	MOV R10, 1
	JMP fim_testa_coli_h
nao_colidiu:
	MOV R10, 0
	
fim_testa_coli_h:
	POP R9
	POP R8
	POP R7
	POP R2
	POP R1
	RET
	
; **********************************************************************
; Rotinas de interrupção 
; **********************************************************************


; **********************************************************************
; ROT_INT_0 - Rotina de atendimento da interrupção 0
;             Assinala o evento na componente 0 da variável tab_eventos_interr
; **********************************************************************
rot_int_0:
     PUSH R0
     PUSH R1
     MOV  R0, tab_eventos_interr
     MOV  R1, 1               ; assinala que houve uma interrupção 0
     MOV  [R0], R1            ; na componente 0 da variável tab_eventos_interr
     POP  R1
     POP  R0
     RFE

; **********************************************************************
; ROT_INT_1 - Rotina de atendimento da interrupção 1
;             Assinala o evento na componente 1 da variável tab_eventos_interr
; **********************************************************************
rot_int_1:
     PUSH R0
     PUSH R1
     MOV  R0, tab_eventos_interr
     MOV  R1, 1               ; assinala que houve uma interrupção 0
     MOV  [R0+2], R1          ; na componente 1 da variável tab_eventos_interr
                              ; Usa-se 2 porque cada word tem 2 bytes
     POP  R1
     POP  R0
     RFE

; **********************************************************************
; ROT_INT_2 - Rotina de atendimento da interrupção 2
;             Assinala o evento na componente 2 da variável tab_eventos_interr
; **********************************************************************
rot_int_2:
     PUSH R0
     PUSH R1
     MOV  R0, tab_eventos_interr
     MOV  R1, 1               ; assinala que houve uma interrupção 0
     MOV  [R0+4], R1          ; na componente 2 da variável tab_eventos_interr
                              ; Usa-se 4 porque cada word tem 2 bytes
     POP  R1
     POP  R0
     RFE
	 
	 
;*****************************************************************************
move_c_b:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	
	MOV R0, pos_pacman
	MOVB R1, [R0]
	ADD R0, 1
	MOVB R2, [R0]					; guarde as componentes da posição atual da nave
	
	MOV R3, R5;LIM_CIM			; se a coluna for LIMITE_DIR, a nave chegou ao limite direito ecrã e não pode andar mais
	CMP R1, R3						; logo sai do processo
	JZ fim_cb

	MOV R3, R6;LIM_CIM_C				; se a coluna for LIMITE_DIR, a nave chegou ao limite direito ecrã e não pode andar mais
	CMP R1, R3						; logo sai do processo
	JNZ c_b
	MOV R3, R7;LIM_DIR_C
	CMP R2, R3
	JLE c_b
	MOV R3, R8;LIM_ESQ_C
	CMP R2, R3
	JGE c_b
	
	JMP fim_cb
c_b:	
	MOV R3, imagem_pacman				
	CALL apaga_obj					; apaga a nave da sua posição atual
	ADD R1, R9						; altera a sua coluna 1 posição para a esquerda
	MOV R3, imagem_pacman_aberto_c
	CALL desenha_obj				; desenha a nave na nova posição (isto faz o efeito de andar para a esquerda)
	CALL time_burner
	MOV R3, imagem_pacman
	CALL desenha_obj
	SUB R0, 1
	MOVB [R0], R1					; guarda a nova coluna da nave na variável
	
	JMP fim_cb

fim_cb:
	
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
move_d_e:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R9
	
	MOV R0, pos_pacman
	MOVB R1, [R0]
	ADD R0, 1
	MOVB R2, [R0]					; guarde as componentes da posição atual da nave
	
	MOV R3, R5;LIM_DIR					; se a coluna for LIMITE_DIR, a nave chegou ao limite direito ecrã e não pode andar mais
	CMP R2, R3						; logo sai do processo
	JZ fim_de 
	MOV R3, R6;LIM_DIR_C				; se a coluna for LIMITE_DIR, a nave chegou ao limite direito ecrã e não pode andar mais
	CMP R2, R3						; logo sai do processo
	JNZ d_e
	MOV R3, R7;LIM_CIM_C
	CMP R1, R3
	JGE d_e
	MOV R3, R8;LIM_BAIX_C
	CMP R1, R3
	JLE d_e
	
	JMP fim_de
d_e:	
	MOV R3, imagem_pacman				
	CALL apaga_obj					; apaga a nave da sua posição atual
	ADD R2, R9						; altera a sua coluna 1 posição para a esquerda
	MOV R3, imagem_pacman_aberto_d
	CALL desenha_obj				; desenha a nave na nova posição (isto faz o efeito de andar para a esquerda)
	CALL time_burner
	MOV R3, imagem_pacman
	CALL desenha_obj
	MOVB [R0], R2					; guarda a nova coluna da nave na variável
	
	JMP fim_de

fim_de:
	
	
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
	POP R1
	POP R0
	RET
	
;**********************************************

	

	