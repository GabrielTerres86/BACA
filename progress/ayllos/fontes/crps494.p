/*..............................................................................

   Programa: fontes/crps494.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Julho/2007                        Ultima atualizacao: 04/11/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importacao de arquivo de atualizacao da data de 
               relacionamento bancario.               
               Atualizar tabelas crapsfn.
               Execucao pela tela PRCBCB.

   Alteracoes: 04/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)

..............................................................................*/

{ includes/var_batch.i } 
   
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

ASSIGN glb_cdprogra = "crps494"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.
   
IF  glb_cdcritic > 0  THEN
    RETURN.

ASSIGN aux_nmarqlog = "log/prcbcb_" + STRING(YEAR(glb_dtmvtolt),"9999") + 
                      STRING(MONTH(glb_dtmvtolt),"99") + 
                      STRING(DAY(glb_dtmvtolt),"99") + ".log".

ASSIGN aux_nmarqrel = "rl/crrl461_999.lst".

{includes/crps492.i}

