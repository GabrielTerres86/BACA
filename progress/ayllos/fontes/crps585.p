/* ............................................................................

   Programa: Fontes/crps585.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vitor
   Data    : Dezembro/2010                       Ultima atualizacao: 13/11/2013

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Atende a solicitacao 004.
               Emitir relatório mensal de acompanhamento de procuracoes
               para cada PAC.
               Relatorio 585.
               
   Alteracoes: 07/02/2011 - Alterado a chamada do fontes/imprim.p para
                            disponibilizar todos os relatórios (Vitor).
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).              
                            
               13/11/2013 - Alterado totalizador de PAs de 99 para 999.
                            (Reinert)                            
   
............................................................................ */ 

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps585"
       glb_cdcritic = 0
       glb_dscritic = "".
       
RUN fontes/iniprg.p.
                                                                        
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

    QUIT.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps585 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF  ERROR-STATUS:ERROR  THEN DO:
    DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
        ASSIGN aux_msgerora = aux_msgerora + 
                              ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
    END.
        
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao executar Stored Procedure: '" +
                      aux_msgerora + "' >> log/proc_batch.log").
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps585 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps585.pr_cdcritic WHEN pc_crps585.pr_cdcritic <> ?
       glb_dscritic = pc_crps585.pr_dscritic WHEN pc_crps585.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps585.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps585.pr_infimsol = 1 THEN
                         TRUE
                      ELSE
                         FALSE.

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

       
/* .......................................................................... */


