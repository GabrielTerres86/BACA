
/*---------------------------------------------------------------------------------------*/
/*  pcrap07.p - Calcular e conferir o digito verificador do CPF.                         */                                              
/*  Objetivo  : Calcular e conferir o digito verificador do CPF.(Antigo fontes/cpffun.p) */
/*---------------------------------------------------------------------------------------*/


DEF INPUT  param nro-calculado AS DECIMAL FORMAT ">>>>>>>>>>>>>99"    NO-UNDO.
DEF OUTPUT param l-retorno     AS LOGICAL                             NO-UNDO.

DEF        VAR aux_confirma AS LOGICAL FORMAT "S/N"                 NO-UNDO.
DEF        VAR aux_digito   AS INT     INIT 0                       NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                       NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                       NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                       NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                       NO-UNDO.

/*   Verifica se o numero informado e' valido   */

IF   LENGTH(STRING(nro-calculado)) < 5   OR
     CAN-DO("11111111111,22222222222,33333333333,44444444444,55555555555," +
	    "66666666666,77777777777,88888888888,99999999999",
	    STRING(nro-calculado))   THEN    DO:
	 l-retorno = FALSE.
	 RETURN.
END.

ASSIGN aux_peso    = 9
       aux_posicao = 0
       aux_calculo = 0.

DO aux_posicao = (LENGTH(STRING(nro-calculado)) - 2) TO 1 BY -1:

   ASSIGN aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(nro-calculado),
					       aux_posicao,1)) * aux_peso)
	      aux_peso    = aux_peso - 1.   

END.  /*  do */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto = 10   THEN
     aux_digito = 0.
ELSE
     aux_digito = aux_resto.

ASSIGN aux_peso    = 8
       aux_posicao = 0
       aux_calculo = aux_digito * 9.

DO aux_posicao = (LENGTH(STRING(nro-calculado)) - 2) TO 1 BY -1:

   ASSIGN aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(nro-calculado),
					    aux_posicao,1)) * aux_peso)
	      aux_peso = aux_peso - 1.

END.  /*  do */

aux_resto = aux_calculo MODULO 11.

IF   aux_resto = 10   THEN
     aux_digito = aux_digito  * 10.      /*  O segundo digito e' 0  */
ELSE
     aux_digito = (aux_digito * 10) + aux_resto.

IF  (INTEGER(SUBSTRING(STRING(nro-calculado),LENGTH(STRING(nro-calculado)) - 1,2))) <> aux_digito   THEN
     l-retorno = FALSE.
ELSE
     l-retorno = TRUE.

/* pcrap07.p */
