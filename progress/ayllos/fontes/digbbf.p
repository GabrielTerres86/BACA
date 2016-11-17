/* .............................................................................

   Programa: Fontes/digbbf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 9                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

IF   LENGTH(STRING(glb_nrcalcul)) < 2   THEN
     DO:
	 glb_stsnrcal = FALSE.
	 RETURN.
     END.

DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 1) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
					    aux_posicao,1)) * aux_peso).

    aux_peso = aux_peso - 1.

    IF   aux_peso = 1   THEN
	 aux_peso = 9.

END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto > 9   THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
		LENGTH(STRING(glb_nrcalcul)),1))) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

glb_nrcalcul = DECIMAL(SUBSTRING(STRING(glb_nrcalcul),1,
				 LENGTH(STRING(glb_nrcalcul)) - 1) +
				 STRING(aux_digito)).

/* .......................................................................... */
