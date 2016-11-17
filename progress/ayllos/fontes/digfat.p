/* .............................................................................

   Programa: Fontes/digfat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Dezembro/95                        Ultima atualizacao: 20/10/92

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze
	       para telefones.

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

DEF        VAR aux_stringvl AS CHAR                                  NO-UNDO.

IF   LENGTH(STRING(glb_nrcalcul)) < 2   THEN
     DO:
	 glb_stsnrcal = FALSE.
	 RETURN.
     END.

aux_stringvl = STRING(glb_nrcalcul,"9999999999999999999999").

DO  aux_posicao = 1 TO 21:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(aux_stringvl,
					    aux_posicao,1)) * aux_peso).

    aux_peso = aux_peso + 1.

END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto > 9   THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

IF  INTEGER(SUBSTRING(aux_stringvl,22,1)) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

glb_nrcalcul = DECIMAL(SUBSTRING(aux_stringvl,1,21) + STRING(aux_digito)).

/* .......................................................................... */
