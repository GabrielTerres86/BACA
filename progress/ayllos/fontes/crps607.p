/* ..........................................................................

   Programa: Fontes/crps607.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gati - Oliver
   Data    : Agosto/2011.                  Ultima atualizacao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Semanal. Solicitacao 70 / Ordem 2 / Cadeia Paralela.
               Roda toda segunda-feira.
                
   Objetivo  : Litar seguros novos, cancelados e renovados do tipo CASA na
               ultima semana. Emite relatorio 607.

   Alteracoes: 22/05/2012 - Alterado busca na crapseg para nao trazer seguros
                            com a data de contrataçao e cancelamento iguais
                            (Guilherme Maba).
                            
               04/03/2013 - Substituido e-mail jeicy@cecred.coop.br por 
                            cecredseguros@cecred.coop.br (Daniele). 
               
               10/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                         
               13/05/2014 - Ajuste na busca de seguros (Douglas)
               
               29/01/2015 - Inclusao do campo de operador no relatorio crrl607
                            SD 248221 (Odirlei-AMcom).
                            
               06/02/2015 - Alterado para exibir o operador que cancelou o seguro no
                            relatorio crrl607 SD 251771 (Odirlei-Amcom)              
                
               22/04/2015 - Criacao do programa hibrido. Alisson (AMcom)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)   
               
........................................................................... */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps607"
       glb_cdcritic = 0
       glb_dscritic = "".
              
RUN fontes/iniprg.p.
                                                               
IF  glb_cdcritic > 0 THEN DO:
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '"  +
                      "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                      "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
    RETURN.
END.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps607 aux_handproc = PROC-HANDLE NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps607 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps607.pr_cdcritic WHEN pc_crps607.pr_cdcritic <> ?
       glb_dscritic = pc_crps607.pr_dscritic WHEN pc_crps607.pr_dscritic <> ?
       glb_stprogra = IF pc_crps607.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps607.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS607.P",
    input glb_cdcooper,
    input 1,
    input 4,
    input 0,
    input 912,
    input "912 - FINALIZADO LEGAL",
    input 1,
    INPUT "", /* nmarqlog */
    INPUT 0,  /* flabrechamado */
    INPUT "", /* texto_chamado */
    INPUT "", /* destinatario_email */
    INPUT 0,  /* flreincidente */
    INPUT 0).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.
{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "PF",
    INPUT "CRPS607.P",
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

/* .......................................................................... */
