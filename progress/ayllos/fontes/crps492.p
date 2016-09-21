/*..............................................................................

   Programa: fontes/crps492.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Sidnei (Precise IT)
   Data    : Julho/2007                        Ultima atualizacao:   /  /    

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Importacao de arquivo de atualizacao da data de 
               relacionamento bancario.               
               Atualizar tabelas crapsfn.
               Execucao na rotina diaria.

   Alteracoes: 

..............................................................................*/

{ includes/var_batch.i }
                          
DEF VAR aux_nmarqlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqrel AS CHAR                                           NO-UNDO.

ASSIGN glb_cdprogra = "crps492"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.
   
IF  glb_cdcritic > 0  THEN
    RETURN.
               
ASSIGN aux_nmarqlog = "log/proc_batch.log".

ASSIGN aux_nmarqrel = "rl/crrl460.lst".

{includes/crps492.i}

