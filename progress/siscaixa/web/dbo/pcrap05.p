
/*----------------------------------------------------------------------------*/
/*  pcrap05.p - Cálculo Dígito Verificador - Título                           */
/*  Objetivo - Calcular e conferir o digito verificador do codigo de barras   */
/*             dos titulos (antigo digcbtit)                                  */                                    
/*----------------------------------------------------------------------------*/

DEF  INPUT PARAM nro-calculado AS DECI                                  NO-UNDO.
DEF OUTPUT PARAM l-retorno     AS LOGI                                  NO-UNDO.

DEF VAR aux_dscalcul AS CHAR                                            NO-UNDO.
                                                     
DEF VAR aux_nrdigbar AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_digito   AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_posicao  AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_peso     AS INTE INIT 2                                     NO-UNDO.
DEF VAR aux_calculo  AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_resto    AS INTE INIT 0                                     NO-UNDO.

IF  nro-calculado = 0  THEN
    DO:
        ASSIGN l-retorno = FALSE. /* Codigo de barras zerado */
        RETURN.
    END.

IF  SUBSTR(STRING(nro-calculado,
           "99999999999999999999999999999999999999999999"),5,1) = "0"  THEN
    DO:
        ASSIGN l-retorno = TRUE. /* Nao tem digito verificador */
        RETURN.
    END.

ASSIGN aux_dscalcul  = STRING(nro-calculado,
                              "99999999999999999999999999999999999999999999")
       nro-calculado = DECI(SUBSTR(aux_dscalcul,01,04) + 
                            SUBSTR(aux_dscalcul,06,39))
       aux_nrdigbar  = INTE(SUBSTR(aux_dscalcul,5,1)).

DO aux_posicao = (LENGTH(STRING(nro-calculado))) TO 1 BY -1:

    ASSIGN aux_calculo = aux_calculo + 
                        (INTE(SUBSTR(STRING(nro-calculado),aux_posicao,1)) * 
                         aux_peso).
           aux_peso    = aux_peso + 1.

    IF  aux_peso > 9  THEN
        aux_peso = 2.

END.

aux_resto = 11 - (aux_calculo MODULO 11).

IF  aux_resto > 9  OR
    aux_resto = 0  OR
    aux_resto = 1  THEN
    aux_digito = 1.
ELSE
    aux_digito = aux_resto.

IF  aux_digito <> aux_nrdigbar  THEN
    l-retorno = FALSE.
ELSE
    l-retorno = TRUE.

nro-calculado = DECI(SUBSTR(aux_dscalcul,01,04) + STRING(aux_digito) + 
                     SUBSTR(aux_dscalcul,06,39)).

/* pcrap05.p */
