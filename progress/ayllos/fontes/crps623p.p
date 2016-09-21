/* ..........................................................................
   Programa: fontes/crps623p.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas R.
   Data    : Julho/2012                   Ultima atualizacao:        

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Limpa a tabela gnapses no banco progrid.

   Alteracoes: 

..............................................................................*/

{ includes/var_batch.i }

DEF        VAR aux_qtdeleta AS INTE                                     NO-UNDO.

ASSIGN aux_qtdeleta = 0.


FOR EACH gnapses WHERE gnapses.dtsessao < (glb_dtmvtolt - 30)  AND
                       gnapses.cdcooper = glb_cdcooper 
                       EXCLUSIVE-LOCK TRANSACTION:

    DELETE gnapses.      
    ASSIGN aux_qtdeleta = aux_qtdeleta + 1.

END.
    
glb_cdcritic = 661.
RUN fontes/critic.p.
UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                   glb_cdprogra + "' --> '" + glb_dscritic + " GNAPSES = " +
                   STRING(aux_qtdeleta,"z,zzz,zz9") + " >> log/proc_batch.log").

/*............................................................................*/
