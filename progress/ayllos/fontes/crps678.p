/* ............................................................................

   Programa: Fontes/crps678.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Rafael Cechet
   Data    : Abril/2014.                       Ultima atualizacao: 
   
   Dados referentes ao programa:

   Frequencia: CRON
   Objetivo  : Integrar arquivos de Custodia de Cheques por Arquivo.
               
   Observacoes: O script /usr/local/cecred/bin/crps678.pl executa este
                programa para integrar os arquivos de custodia de cheque
                enviados pelos cooperados.
                
                Horario de execucao: todos os dias, das 6:00h as 22:00h
                                     a cada 15 minutos.
               

   Alteracao : 28/04/2014 - Criado fonte crps678 (Rafael)
   
............................................................................ */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps678"
       glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcooper = 3. 

/*RUN fontes/iniprg.p.*/

IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps678 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),
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
    RETURN.
END.

CLOSE STORED-PROCEDURE pc_crps678 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps678.pr_cdcritic WHEN pc_crps678.pr_cdcritic <> ?
       glb_dscritic = pc_crps678.pr_dscritic WHEN pc_crps678.pr_dscritic <> ?
       glb_stprogra = IF pc_crps678.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps678.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

IF  glb_cdcritic <> 0   OR
    glb_dscritic <> ""  THEN
    DO:
        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                          " - " + glb_cdprogra + "' --> '"  +
                          "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                          "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
        RETURN.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
/* RUN fontes/fimprg.p. */
 
