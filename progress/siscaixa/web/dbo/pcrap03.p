/*----------------------------------------------------------------------------*/
/*  pcrap03.p - Calculo Digito Verificador                                    */
/*  Objetivo: Calcular e conferir o digito verificador pelo modulo dez.       */
/*   (Algoritmo fornecido pelo BANCO DO BRASIL - Gerson) (Antigo digm10.p)    */
/*                                                                            */
/*  Alteracoes: 15/12/2008 - Incluir parametro para validar tamanho do valor  */
/*                           que sera validado (David).                       */
/*----------------------------------------------------------------------------*/

DEF INPUT-OUTPUT PARAM nro-calculado AS DECI                           NO-UNDO.
DEF INPUT        PARAM vld-zeros     AS LOGI                           NO-UNDO.
DEF       OUTPUT PARAM nro-digito    AS INTE                           NO-UNDO.
DEF       OUTPUT PARAM l-retorno     AS LOGI                           NO-UNDO.

DEF VAR aux_digito  AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_posicao AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_peso    AS INTE INIT 2                                     NO-UNDO.
DEF VAR aux_calculo AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_dezena  AS INTE INIT 0                                     NO-UNDO.
DEF VAR aux_resulta AS INTE INIT 0                                     NO-UNDO.

IF  vld-zeros AND LENGTH(STRING(nro-calculado)) < 2  THEN 
    DO:
        l-retorno = FALSE.
        RETURN.
    END.

DO aux_posicao = LENGTH(STRING(nro-calculado)) - 1 TO 1 BY -1:

    aux_resulta = INTE(SUBSTR(STRING(nro-calculado),aux_posicao,1)) * aux_peso.

    IF  aux_resulta > 9  THEN
        aux_resulta = INTE(SUBSTR(STRING(aux_resulta,"99"),1,1)) +
                      INTE(SUBSTR(STRING(aux_resulta,"99"),2,1)).

    ASSIGN aux_calculo = aux_calculo + aux_resulta
           aux_peso    = aux_peso - 1.

    IF  aux_peso = 0  THEN
        aux_peso = 2.

END. /* Fim do DO ... TO */

ASSIGN aux_dezena = (INTE(SUBSTR(STRING(aux_calculo,"999"),1,2)) + 1) * 10
       aux_digito = aux_dezena - aux_calculo.

IF  aux_digito = 10  THEN
    aux_digito = 0.

IF  INTE(SUBSTR(STRING(nro-calculado),
         LENGTH(STRING(nro-calculado)),1)) <> aux_digito  THEN
    l-retorno = FALSE.
ELSE
    l-retorno = TRUE.

ASSIGN nro-calculado = DECI(SUBSTR(STRING(nro-calculado),1,
                            LENGTH(STRING(nro-calculado)) - 1) +
                            STRING(aux_digito))
       nro-digito    = aux_digito.

/*----------------------------------------------------------------------------*/
