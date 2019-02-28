/* ..........................................................................

   Programa: Fontes/crps128.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : 18/07/95                            Ultima alteracao: 20/02/2019

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Emite relatorio com os maiores depositos em conta-corrente.

               Atende solicitacao 002.
               Relatorio 105
               Ordem do programa na solicitacao : 009
               Exclusividade 2.

   Alteracoes: 21/08/95 - Alterado para rodar somente as segundas-feiras e
                          colocado o turno (Deborah).

               10/04/96 - Alterado para listar poupanca programada (Odair).

               25/11/96 - Tratar RDCAII (Odair).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               04/01/2000 - Nao gerar pedido de impressao (Deborah). 
               
               07/03/2001 - Acrescentar o numero do telefone residencial do 
                            associado no relatorio. (Ze Eduardo).

               16/09/2003 - Aumentar campos de valores (Deborah).

               30/10/2003 - Substituido comando RETURN pelo QUIT(Mirtes).
               
               06/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).
                            
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               22/06/2007 - Somente considera aplicacoes RDCA30 e RDCA60 na
                            tabela de aplicacoes RDCA (Elton). 

               31/07/2007 - Tratamento para aplicacoes RDC (David).

               26/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise)
                            
                          - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).
                            
               12/09/2008 - Substituido arquivo crrl105.tmp por uma TEMP TABLE
                            e retirado comando "sort" (Diego).
                            
               14/10/2008 - Acerto qdo descarrega a BO 4 - DELETE PROCEDURE (Ze)

               10/10/2013 - Chamada Stored Procedure do Oracle
                            (Andre Euzebio / Supero)
                             
               20/02/2019 - Inclusao de log de fim de execucao do programa 
                            (Belli - Envolti - Chamado REQ0039739)
							
............................................................................. */
{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps128"
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

RUN STORED-PROCEDURE pc_crps128 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps128 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps128.pr_cdcritic WHEN pc_crps128.pr_cdcritic <> ?
       glb_dscritic = pc_crps128.pr_dscritic WHEN pc_crps128.pr_dscritic <> ?
       glb_stprogra = IF pc_crps128.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps128.pr_infimsol = 1 THEN TRUE ELSE FALSE.
       
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

/* Inclusao de log de fim de execucao do programa -  20/02/2019 - Chamado REQ0039739 */

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
   (INPUT "O",
    INPUT "CRPS128.P",
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
    INPUT "CRPS128.P",
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

