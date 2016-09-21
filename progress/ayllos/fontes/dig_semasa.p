/* .............................................................................

   Programa: Fontes/dig_semasa.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : Abril/2008                        Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Sempre que chamado por outros programas.
   Objetivo  : Calcular e conferir o digito verificador para SEMASA.
               Disponibilizar nro calculado digito "X".

   Alteracoes: 
............................................................................. */

DEF SHARED VAR glb_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9"       NO-UNDO.
DEF SHARED VAR glb_stsnrcal AS LOGICAL                               NO-UNDO.

DEF        VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_peso     AS INT     EXTENT 10  INIT [5,3,3,2,7,6,5,4,3,2]
                                                                     NO-UNDO.
DEF        VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_resto    AS INT     INIT 0                        NO-UNDO.
DEF        VAR aux_indice   AS INT                                   NO-UNDO.
             
IF   LENGTH(STRING(glb_nrcalcul)) < 2   THEN
     DO:
         glb_stsnrcal = FALSE.
         RETURN.
     END.

ASSIGN  aux_indice = 10.

DO  aux_posicao = (LENGTH(STRING(glb_nrcalcul)) - 1) TO 1 BY -1:
                            
    aux_calculo = aux_calculo + (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                                        aux_posicao,1)) * aux_peso[aux_indice]).
    aux_indice = aux_indice - 1.
    
END.  /*  Fim do DO .. TO  */

aux_resto = aux_calculo MODULO 11.

IF  aux_resto > 1 AND aux_resto < 10 THEN 
    aux_digito = 11 - aux_resto.
ELSE
    aux_digito = 0.

IF  (INTEGER(SUBSTRING(STRING(glb_nrcalcul),
                LENGTH(STRING(glb_nrcalcul)),1))) <> aux_digito   THEN
     glb_stsnrcal = FALSE.
ELSE
     glb_stsnrcal = TRUE.

/** Substituicao do numero do digito errado pelo numero correto **/
glb_nrcalcul = DECIMAL(SUBSTRING(STRING(glb_nrcalcul),1,
                                 LENGTH(STRING(glb_nrcalcul)) - 1) +
                                 STRING(aux_digito)).
                                 
