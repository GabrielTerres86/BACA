/* ............................................................................

   Programa: fontes/crps522.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Novembro/2008                   Ultima atualizacao: 12/09/2013

   Dados referentes ao programa:

   Frequencia: Semestral.
   Objetivo  : Atende a solicitacao 105.
               Geracao da DIMOF para a Receita Federal.

   Alteracoes: 19/10/2009 - Alteracao Codigo Historico (Kbase).
   
               03/03/2010 - Alteracao Historico (Gati)
               
               09/08/2010 - Alterada ordem da solicitacao dentro do crapord de
                            261 para 71. Programa paralelo chamado no meio
                            da cadeia exclusiva. (Magui).
                            
               13/08/2010 - Ajustado problema com leitura da TEMP-TABLE tt-hist
                            (Fernando).             
                            
               09/06/2011 - Alteracao para atender aos padroes do novo layout
                            (Adriano).             
                            
               22/08/2011 - Desprezar lancto da conta 2652404 indevido (Magui).
               
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                            
               12/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps522"
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

RUN STORED-PROCEDURE pc_crps522 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps522 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps522.pr_cdcritic WHEN pc_crps522.pr_cdcritic <> ?
       glb_dscritic = pc_crps522.pr_dscritic WHEN pc_crps522.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps522.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps522.pr_infimsol = 1 THEN
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