/* .............................................................................

   Programa: Fontes/cgcfun.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                        Ultima alteracao: 20/11/97

   Dados referentes ao programa:

   Frequencia: Sempre que chamado pelo programa fontes/cpfcgc.p.
   Objetivo  : Calcular e conferir o digito verificador do CGC.

   Alteracoes: 20/11/97 - Alterado para inibir a critica ao oitavo digito.

ATENCAO!!! - A documentacao da rotina enviada pela RECEITA FEDERAL esta na
             pasta da tela MATRIC.

............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.
DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resultad AS INT     INIT 0                        NO-UNDO.

/*   Verifica se o numero a ser calculado e' valido   */

IF   LENGTH(STRING(glb_nrcalcul)) < 3   THEN
     DO:
         glb_stsnrcal = false.
         RETURN.
     END.


/*   Calculo do digito 8 do CGC.   */

aux_calculo = INTEGER(SUBSTRING(STRING(glb_nrcalcul,">>>>>>>>>>>>>9"),1,1)) * 2.
aux_resultad = INTEGER(SUBSTRING(STRING(glb_nrcalcul ,">>>>>>>>>>>>>9"),2,1)) +
               INTEGER(SUBSTRING(STRING(glb_nrcalcul ,">>>>>>>>>>>>>9"),4,1)) +
               INTEGER(SUBSTRING(STRING(glb_nrcalcul ,">>>>>>>>>>>>>9"),6,1)) +
               INTEGER(SUBSTRING(STRING(aux_calculo                   ),1,1)) +
               INTEGER(SUBSTRING(STRING(aux_calculo                   ),2,1)).

aux_calculo = INTEGER(SUBSTRING(STRING(glb_nrcalcul,">>>>>>>>>>>>>9"),3,1)) * 2.
aux_resultad = aux_resultad +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_calculo = INTEGER(SUBSTRING(STRING(glb_nrcalcul,">>>>>>>>>>>>>9"),5,1)) * 2.
aux_resultad = aux_resultad +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_calculo = INTEGER(SUBSTRING(STRING(glb_nrcalcul,">>>>>>>>>>>>>9"),7,1)) * 2.
aux_resultad = aux_resultad +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),1,1)) +
              INTEGER(SUBSTRING(STRING(aux_calculo                  ),2,1)).

aux_resto = aux_resultad MODULO 10.

IF   aux_resto = 0   THEN
     aux_digito = aux_resto.
ELSE
     aux_digito = 10 - aux_resto.

/* Comentado em 20/11/97

IF   aux_digito <> INTEGER(SUBSTRING(STRING(glb_nrcalcul,">>>>>>>>>>>>>9"),8,1))
     THEN
          DO:
              glb_stsnrcal = FALSE.
              RETURN.
          END.
*/

/*   Calculo do digito 13 do CGC.   */

aux_calculo = 0.

DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 2) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
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

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                LENGTH(STRING(glb_nrcalcul)) - 1,1))) <> aux_digito   THEN
     DO:
         glb_stsnrcal = FALSE.
         RETURN.
     END.


/*   Calculo do digito 14 do CGC.   */

aux_peso    = 2.
aux_posicao = 0.
aux_calculo = 0.

DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 1) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
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

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                LENGTH(STRING(glb_nrcalcul)),1))) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

/* .......................................................................... */
