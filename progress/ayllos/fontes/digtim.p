/* .............................................................................

   Programa: Fontes/digtim.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/99                         Ultima atualizacao: 10/05/2003

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador pelo modulo onze
               da tim telesc.

   Alteracoes: 10/05/2003 - Alteracao no calculo do Digito Verificador (ZE).
............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>>>>>>>9"  NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                                NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_peso     AS INT     INIT 9                         NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                         NO-UNDO.
DEF        VAR aux_strnume  AS CHAR                                   NO-UNDO.

IF   LENGTH(STRING(glb_nrcalcul)) < 2   THEN
     DO:
         glb_stsnrcal = FALSE.
         RETURN.
     END.

aux_strnume = STRING(glb_nrcalcul,"99999999999999999999").

aux_peso = 4.  /*  alimenta a tabela de pesos e multiplica para cada digito  */

DO aux_posicao = 1 TO 19:

   aux_calculo = aux_calculo + 
        INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso.

   aux_peso = IF   aux_peso = 2 THEN
                   9
              ELSE aux_peso - 1.
END.

aux_resto = aux_calculo MODULO 11.

IF    aux_resto = 0 OR
      aux_resto = 1 THEN
      aux_digito = 0.
ELSE   
      aux_digito = 11 - aux_resto.

IF   (INTEGER(SUBSTRING(aux_strnume,LENGTH(aux_strnume),1))) <> aux_digito THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

glb_nrcalcul = DECIMAL(SUBSTRING(aux_strnume,1, LENGTH(aux_strnume) - 1) +
                                 STRING(aux_digito)).

/* .......................................................................... */