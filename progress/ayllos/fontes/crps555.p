/*..............................................................................

   Programa: fontes/crps555.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Fevereiro/2010                      Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Fonte baseado no crps492
               Atende a solicitacao 1
               Importacao de arquivo de atualizacao da data de relacionamento
               bancario.
               Atualizar tabelas crapsfn.
               Execucao na rotina diaria.
               Gera relatorio crrl557.lst 

   Alteracoes: 

..............................................................................*/

{ includes/var_batch.i }
                          
DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

ASSIGN glb_cdprogra = "crps555"
       glb_flgbatch = FALSE 
       aux_nmarqlog = "log/proc_batch.log"
       aux_nmarqrel = "rl/crrl557.lst".

RUN fontes/iniprg.p.

IF  glb_cdcritic > 0  THEN
    RETURN.

{ includes/crps555.i }

/*............................................................................*/
