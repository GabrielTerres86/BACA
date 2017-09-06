/*..........................................................................

   Programa: Fontes/crps100.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94                         Ultima atualizacao: 01/09/2017 

   Dados referentes ao programa:

   Frequencia: Batch - Background.

   Objetivo  : Emitir a listagem de acompanhamento do utilizado, saque e
               adiantamento.
               Relatorio 84.
               Atende a solicitacao  55.
               Ordem da Solicitacao 043.
               Exclusividade 2.
               Ordem do programa na solicitacao = 1.

   Alteracoes: Tratar conversao para v8 (Odair)
   
               05/05/2000 - Listar o pac (Odair)

               01/06/2000 - Alterar formulario (Odair)

               04/10/2001 - Incluir qtddusol (Margarete).
               
               28/02/2002 - Separar por PAC (Ze Eduardo).
               
               23/07/2003 - Incluir "CL-" no nome dos associados que estao em
                            "credito em liquidacao" (Julio).

               12/08/2003 - Mudanca no calculo do utilizado (Deborah).

               29/08/2005 - Incluido total de associados que possuem limite de
                            credito, e total de associados que utilizam esse   
                            limite de credito (Diego). 

               14/02/2006 - Alterado Resumo Geral Por PAC, para listar o total
                            separado entre Contas Fisicas e Juridicas (Diego).
                            
               15/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               07/04/2008 - Lista todos os PACs que tenham associados com
                            limite de credito, mesmo que o limite nao esteja
                            sendo utilizado (Elton).
               
               12/09/2013 - Conversao oracle, chamada da stored procedure
                            (Andre Euzebio / Supero).
                            
               01/09/2017 - Inclusao de log de fim de execucao do programa 
                            (Carlos)
 
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps100"
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

RUN STORED-PROCEDURE pc_crps100 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps100 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps100.pr_cdcritic WHEN pc_crps100.pr_cdcritic <> ?
       glb_dscritic = pc_crps100.pr_dscritic WHEN pc_crps100.pr_dscritic <> ?
       glb_stprogra = IF pc_crps100.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps100.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
              
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

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS100.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 0,
    input "",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
                  
RUN fontes/fimprg.p.


