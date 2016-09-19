/* ............................................................................

   Programa: Fontes/crps440.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2005                        Ultima atualizacao: 02/04/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Listar relatorio com seguros a vencer no mes seguinte
               (tipo >= 11).
               Solicitacao 87, ordem 7
               Emite o relatorio 417.
               
   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/04/2008 - Alterado formato do campo "crapseg.qtprepag", de  
                           "z9" para "zz9" - Kbase IT Solutions - Eduardo.
               
               16/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).        
                                                        
               26/11/2013 - Adicionado o nr. proposta na Ordenacao
                            Projeto Oracle (Guilherme).
                            
               02/04/2015 - Conversao oracle --> Chamada da Stored procedure
                            (Lucas Ranghetti)
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps440"
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

RUN STORED-PROCEDURE pc_crps440 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps440 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps440.pr_cdcritic WHEN pc_crps440.pr_cdcritic <> ?
       glb_dscritic = pc_crps440.pr_dscritic WHEN pc_crps440.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps440.pr_stprogra = 1 THEN 
                          TRUE 
                      ELSE 
                          FALSE
       glb_infimsol = IF  pc_crps440.pr_infimsol = 1 THEN 
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

/* ............................................................................. */
