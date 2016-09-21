/* .............................................................................

   Programa: Fontes/cpffun.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91.                        Ultima atualizacao: 28/10/97

   Dados referentes ao programa:

   Frequencia: Sempre que chamado pelo programa fontes/cpfcgc.p.
   Objetivo  : Calcular e conferir o digito verificador do CPF.

   ATENCAO!!! - A documentacao da rotina enviada pela RECEITA FEDERAL esta na
		pasta da tela MATRIC.

   Alteracoes: 03/02/95 - Alterado para inibir o calculo do primeiro digito
			  quando a regiao for 4 (Deborah).

	       28/10/97 - Nova rotina de calculo de CPF conforme algoritmo
			  recebido do RH - Depine'   (Edson).

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>99"      NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_confirma AS LOGICAL FORMAT "S/N"                  NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

/*   Verifica se o numero informado e' valido   */

IF   LENGTH(STRING(glb_nrcalcul)) < 5   OR
     CAN-DO("11111111111,22222222222,33333333333,44444444444,55555555555," +
	    "66666666666,77777777777,88888888888,99999999999",
	    STRING(glb_nrcalcul))   THEN
     DO:
	 glb_stsnrcal = FALSE.
	 RETURN.
     END.

ASSIGN aux_peso    = 9
       aux_posicao = 0
       aux_calculo = 0.

DO aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 2) TO 1 BY -1:

   ASSIGN aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
					       aux_posicao,1)) * aux_peso)
	  aux_peso = aux_peso - 1.

END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto = 10   THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

ASSIGN aux_peso    = 8
       aux_posicao = 0
       aux_calculo = aux_digito * 9.

DO aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 2) TO 1 BY -1:

   ASSIGN aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
					       aux_posicao,1)) * aux_peso)
	  aux_peso = aux_peso - 1.

END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto = 10   THEN
     aux_digito = aux_digito * 10.      /*  O segundo digito e' 0  */
ELSE
     aux_digito = (aux_digito * 10) + aux_resto.

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
		LENGTH(STRING(glb_nrcalcul)) - 1,2))) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

/*                             fora de uso - nao deve ser usada
IF   NOT glb_stsnrcal   THEN
     DO:
	 aux_confirma = FALSE.
	 BELL.
	 MESSAGE COLOR NORMAL
		 "027 - CPF com erro. Aceitar? (S/N): " UPDATE aux_confirma.

	 IF   aux_confirma   THEN
	      glb_stsnrcal = TRUE.
     END.
*/
/* .......................................................................... */
