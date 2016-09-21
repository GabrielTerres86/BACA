/*----------------------------------------------------------------------------*/
/*  pcrap04.p - Calculo Digito Verificador                                    */
/*  Objetivo - Calcular e conferir o digito verificador do codigo de barras   */
/*             dos titulos compensaveis IPTU E SAMAE BLUMENAU(antigo          */
/*             cdbarra3.p).                                                   */ /*----------------------------------------------------------------------------*/

DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.

 
DEF   VAR aux_dscorbar AS CHAR                                  NO-UNDO.
DEF   VAR aux_dscalcul AS CHAR                                  NO-UNDO.
DEF   VAR aux_conver   AS CHAR                                  NO-UNDO.

DEF   VAR aux_nrdigbar AS INT     INIT 0                        NO-UNDO.
DEF   VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF   VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF   VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF   VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF   VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

ASSIGN aux_dscorbar = STRING(nro-calculado,FILL("9",44))
       aux_dscalcul = SUBSTR(aux_dscorbar,01,03) + SUBSTR(aux_dscorbar,05,40)
       aux_nrdigbar = INTE(SUBSTR(aux_dscorbar,4,1))
       aux_peso     = 2.

DO aux_posicao = 1 TO LENGTH(STRING(aux_dscalcul)):
   
    ASSIGN aux_conver = STRING(INTE(SUBSTR(STRING(aux_dscalcul),
                                           aux_posicao,1)) * aux_peso).
    
    IF  LENGTH(aux_conver) = 2  THEN 
        DO:
            ASSIGN aux_calculo = aux_calculo + 
                                 INTE(SUBSTR(aux_conver,1,1)) +
                                 INTE(SUBSTR(aux_conver,2,1)).
        END.
    ELSE
        ASSIGN aux_calculo = aux_calculo + INTE(aux_conver).

    IF  aux_peso = 2  THEN
        ASSIGN aux_peso = 1.
    ELSE 
        ASSIGN aux_peso = 2.

END.  

ASSIGN aux_resto = 10 - (aux_calculo MODULO 10).

IF  aux_resto = 10  THEN
    ASSIGN aux_digito = 0.
ELSE
    ASSIGN aux_digito = aux_resto.

IF  aux_digito <> aux_nrdigbar  THEN
    ASSIGN l-retorno = FALSE.
ELSE
    ASSIGN l-retorno = TRUE.

ASSIGN nro-digito    = aux_digito
       nro-calculado = DECI(SUBSTR(aux_dscorbar,01,03) + STRING(aux_digito) +
                            SUBSTR(aux_dscorbar,05,40)).
