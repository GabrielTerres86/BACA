
/* ............................................................................

   Programa: fontes/crpn616.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2012                       Ultima atualizacao: 20/06/2017

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Atualizar saldo das parcelas de todos os contratos de emprestimo

   Alteracoes: 15/01/2013 - Atualizar o campo crapepr.dtdpagto com a data da
                            primeira parcela não liquidada.
                           (David Kruger).   
                           
               12/07/2013 - Ajuste na gravacao de juros + 60 (Gabriel).
               
               06/12/2013 - Ajuste para melhorar a performance (James).
               
               20/06/2017 - #696286 programa piloto com Altovale para melhoria 
                            de performance. Valor do campo crapprg.cdprogra 
                            alterado para crpn616 (altovale) para testes (Carlos)

.............................................................................*/

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crpn616"
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


/* ============== Rodar CRPS616_NEW (rollback + export) ================== */

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PI",
                     INPUT "CRPS616_NEW",
                     input glb_cdcooper,
                     input 1, /* tpexecucao */
                     input 4, /* tpocorrencia */
                     input 0, /* cdcriticidade */
                     input 0, /* cdmensagem */
                     input "", /* dsmensagem */                                          
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0   /* idprglog */
                     ).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.

RUN STORED-PROCEDURE pc_crps616_new aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps616_new WHERE PROC-HANDLE = aux_handproc.

RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PF",
                     INPUT "CRPS616_NEW",
                     input glb_cdcooper,
                     input 1, /* tpexecucao */
                     input 4, /* tpocorrencia */
                     input 0, /* cdcriticidade */
                     input 0, /* cdmensagem */
                     input "", /* dsmensagem */                                          
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0   /* idprglog */                     
                     ).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps616_new.pr_cdcritic WHEN pc_crps616_new.pr_cdcritic <> ?
       glb_dscritic = pc_crps616_new.pr_dscritic WHEN pc_crps616_new.pr_dscritic <> ?
       glb_stprogra = IF pc_crps616_new.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps616_new.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
/*
RUN fontes/fimprg.p. */

/* ============== Fim CRPS616_NEW (rollback + export) ================== */






/* ============== Rodar CRPS616_OLD (export) =========================== */

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PI",
                     INPUT "CRPS616_OLD",
                     input glb_cdcooper,
                     input 1, /* tpexecucao */
                     input 4, /* tpocorrencia */
                     input 0, /* cdcriticidade */
                     input 0, /* cdmensagem */
                     input "", /* dsmensagem */                                          
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0   /* idprglog */
                     ).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.

RUN STORED-PROCEDURE pc_crps616_old aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps616_old WHERE PROC-HANDLE = aux_handproc.

RUN STORED-PROCEDURE pc_log_programa aux_handproc = PROC-HANDLE
                    (INPUT "PF",
                     INPUT "CRPS616_OLD",
                     input glb_cdcooper,
                     input 1, /* tpexecucao */
                     input 4, /* tpocorrencia */
                     input 0, /* cdcriticidade */
                     input 0, /* cdmensagem */
                     input "", /* dsmensagem */                                          
                     input 1,  /* flgsucesso */
                     INPUT "", /* nmarqlog */
                     input 0,  /* flabrechamado */
                     input "", /* texto_chamado */
                     input "", /* destinatario_email */
                     input 0,  /* flreincidente */
                     INPUT 0   /* idprglog */                     
                     ).
CLOSE STORED-PROCEDURE pc_log_programa WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps616_old.pr_cdcritic WHEN pc_crps616_old.pr_cdcritic <> ?
       glb_dscritic = pc_crps616_old.pr_dscritic WHEN pc_crps616_old.pr_dscritic <> ?
       glb_stprogra = IF pc_crps616_old.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps616_old.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

RUN fontes/fimprg.p. 
/* ============== Fim CRPS616_OLD (export) ============================= */
