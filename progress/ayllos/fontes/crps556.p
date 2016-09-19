/*..............................................................................

   Programa: fontes/crps556.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Fevereiro/2010                    Ultima atualizacao: 05/04/2010

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps494
               Importacao de arquivo de atualizacao da data de 
               relacionamento bancario.               
               Atualizar tabelas crapsfn.
               Execucao pela tela PRCCTL.
               Gera relatorio crrl558_99

   Alteracoes: 05/04/2010 - Alterado para processar todas cooperativas, nao
                            mais por cooperativa Singular (Guilherme/Supero)

..............................................................................*/

{ includes/var_batch.i } 

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

ASSIGN glb_cdprogra = "crps556"
       glb_flgbatch = FALSE 
       aux_nmarqlog = "/usr/coop/cecred/log/prcctl_" +
                      STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".
       aux_nmarqrel = "rl/crrl558.lst".

RUN fontes/iniprg.p.
   
IF  glb_cdcritic > 0  THEN
    RETURN.

{ includes/crps555.i }
/*............................................................................*/
