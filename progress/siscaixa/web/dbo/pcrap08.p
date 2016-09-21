
/*---------------------------------------------------------------------------------------*/
/*  pcrap08.p - Calcular e conferir o digito verificador do CPGC.                         */                                              
/*  Objetivo  : Calcular e conferir o digito verificador do CGC.(Antigo fontes/cgcfun.p) */
/*---------------------------------------------------------------------------------------*/


DEF INPUT param  nro-calculado AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF OUTPUT PARAM l-retorno     AS LOGICAL                               NO-UNDO.
DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resultad AS INT     INIT 0                        NO-UNDO.

/*   Verifica se o numero a ser calculado e' valido   */

IF   LENGTH(STRING(nro-calculado)) < 3   THEN DO:
	 l-retorno = false.
	 RETURN.
END.

/*   Calculo do digito 8 do CGC.   */
aux_calculo  = INTEGER(SUBSTRING(STRING(nro-calculado,">>>>>>>>>>>>>9"),1,1)) * 2.
aux_resultad = INTEGER(SUBSTRING(STRING(nro-calculado ,">>>>>>>>>>>>>9"),2,1)) +
	           INTEGER(SUBSTRING(STRING(nro-calculado ,">>>>>>>>>>>>>9"),4,1)) +
	           INTEGER(SUBSTRING(STRING(nro-calculado ,">>>>>>>>>>>>>9"),6,1)) +
	           INTEGER(SUBSTRING(STRING(aux_calculo                   ),1,1)) +
	           INTEGER(SUBSTRING(STRING(aux_calculo                   ),2,1)).

aux_calculo  = INTEGER(SUBSTRING(STRING(nro-calculado,">>>>>>>>>>>>>9"),3,1)) * 2.
aux_resultad = aux_resultad +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_calculo  = INTEGER(SUBSTRING(STRING(nro-calculado,">>>>>>>>>>>>>9"),5,1)) * 2.
aux_resultad = aux_resultad +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_calculo  = INTEGER(SUBSTRING(STRING(nro-calculado,">>>>>>>>>>>>>9"),7,1)) * 2.
aux_resultad = aux_resultad +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
	           INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_resto = aux_resultad MODULO 10.

IF   aux_resto = 0   THEN
     aux_digito = aux_resto.
ELSE
     aux_digito = 10 - aux_resto.


/*   Calculo do digito 13 do CGC.   */

aux_calculo = 0.

DO  aux_posicao = (LENGTH(STRING(nro-calculado)) - 2) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(nro-calculado),
					    aux_posicao,1)) * aux_peso).
    aux_peso = aux_peso + 1.

    IF   aux_peso > 9   THEN
	 aux_peso = 2.

END.

aux_resto = aux_calculo MODULO 11.

IF   aux_resto < 2   THEN
     aux_digito = 0.
ELSE
     aux_digito = 11 - aux_resto.

IF  (INTEGER(SUBSTRING(STRING(nro-calculado),
		LENGTH(STRING(nro-calculado)) - 1,1))) <> aux_digito   THEN
     DO:
	 l-retorno = FALSE.
	 RETURN.
     END.


/*   Calculo do digito 14 do CGC.   */

aux_peso    = 2.
aux_posicao = 0.
aux_calculo = 0.

DO  aux_posicao = (LENGTH(STRING(nro-calculado)) - 1) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(nro-calculado),
					    aux_posicao,1)) * aux_peso).
    aux_peso = aux_peso + 1.

    IF   aux_peso > 9   THEN
	 aux_peso = 2.

END.

aux_resto = aux_calculo MODULO 11.

IF   aux_resto < 2   THEN
     aux_digito = 0.
ELSE
     aux_digito = 11 - aux_resto.

IF  (INTEGER(SUBSTRING(STRING(nro-calculado),
		LENGTH(STRING(nro-calculado)),1))) <> aux_digito   THEN
     l-retorno = FALSE.
ELSE
     l-retorno = TRUE.

/* pcrap08.p */
