/* .............................................................................

   Programa: Fontes/digcbtit.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                         Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador do codigo de barras
               dos titulos compensaveis.
               
............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL                               NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_dscalcul AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdigbar AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

IF   INTEGER(SUBSTRING(STRING(glb_nrcalcul,
                             "99999999999999999999999999999999999999999999"),
                       5,1)) = 0   THEN
     DO:
         glb_stsnrcal = TRUE.     /*  Nao tem digito verificador  */
         RETURN.
     END.

ASSIGN aux_dscalcul = STRING(glb_nrcalcul,
                             "99999999999999999999999999999999999999999999")

       glb_nrcalcul = DECIMAL(SUBSTRING(aux_dscalcul,01,04) +
                              SUBSTRING(aux_dscalcul,06,39))
                              
       aux_nrdigbar = INTEGER(SUBSTRING(aux_dscalcul,5,1)).
       
DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul))) TO 1 BY -1:

    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                                            aux_posicao,1)) * aux_peso).
    aux_peso = aux_peso + 1.

    if   aux_peso > 9   THEN
         aux_peso = 2.

END.  /*  Fim do DO .. TO  */

aux_resto = 11 - (aux_calculo MODULO 11).

IF   aux_resto > 9   OR
     aux_resto = 0   OR
     aux_resto = 1   THEN
     aux_digito = 1.
ELSE
     aux_digito = aux_resto.

IF   aux_digito <> aux_nrdigbar   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

glb_nrcalcul = DECIMAL(SUBSTRING(aux_dscalcul,01,04) +
                       STRING(aux_digito) +
                       SUBSTRING(aux_dscalcul,06,39)).

/* .......................................................................... */
