/* .............................................................................

   Programa: Fontes/digm10.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Fevereiro/99.                       Ultima atualizacao:   /  /  

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo dez.
               (Algoritmo fornecido pelo BANCO DO BRASIL - Gerson)

............................................................................. */

DEF INPUT-OUTPUT PARAM glb_nrcalcul AS DECIMAL                       NO-UNDO.
DEF OUTPUT       PARAM glb_nrdigito AS INTEGER                       NO-UNDO.
DEF OUTPUT       PARAM glb_stsnrcal AS LOGICAL                       NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_dezena   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resulta  AS INT     INIT 0                        NO-UNDO.

IF   LENGTH(STRING(glb_nrcalcul)) < 2   THEN
     DO:
         glb_stsnrcal = FALSE.
         RETURN.
     END.

DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 1) TO 1 BY -1:

    aux_resulta = (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                               aux_posicao,1)) * aux_peso).

    IF   aux_resulta > 9   THEN
         aux_resulta = INT(SUBSTRING(STRING(aux_resulta,'99'),1,1)) +
                       INT(SUBSTRING(STRING(aux_resulta,'99'),2,1)).

    ASSIGN aux_calculo = aux_calculo + aux_resulta

           aux_peso = aux_peso - 1.

    IF   aux_peso = 0   THEN
         aux_peso = 2.

END.  /*  Fim do DO .. TO  */

ASSIGN aux_dezena = (INT(SUBSTRING(STRING(aux_calculo,'999'),1,2)) + 1) * 10
       aux_digito = aux_dezena - aux_calculo.

IF   aux_digito = 10   THEN
     aux_digito = 0.

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                LENGTH(STRING(glb_nrcalcul)),1))) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

ASSIGN glb_nrcalcul = DECIMAL(SUBSTRING(STRING(glb_nrcalcul),1,
                               LENGTH(STRING(glb_nrcalcul)) - 1) +
                              STRING(aux_digito))
                              
       glb_nrdigito = aux_digito.

/* .......................................................................... */
