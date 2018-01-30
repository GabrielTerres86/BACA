/* ..........................................................................

   Programa: Fontes/crps024.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Maio/92.                            Ultima atualizacao: 18/01/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 16.
               Acompanhamento dos talonarios quinzenalmente (25).

   Alteracao : 07/12/95 - Fazer o mesmo tratamento dado ao tipo de conta 5 para
                          o tipo de conta 6 (Odair).

               24/03/98 - Incluir a empresa no relatorio (Deborah).

               11/09/98 - Tratar tipo de conta 7 (Deborah).

               01/07/99 - Nao selicionar cheques de transferencia (Odair)
               
             01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

             18/10/2004 - Tratar conta integracao (Margarete).
             
             09/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
             
             15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

             21/07/2008 - Alterado formato dos campos relacionados a Media dos
                          cheques (Elton).
                          
             01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
             
             17/02/2010 - Aumentar formatos dos campos totais (Gabriel).
             
             06/12/2011 - Sustagco provissria (Andri R./Supero).
             
             06/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)

             18/01/2018 - Projeto Ligeirinho. Fabiano Girardi AMcom Adicionado parametros.                            
             
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }
                             
ASSIGN glb_cdprogra = "crps024"
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

RUN STORED-PROCEDURE pc_crps024 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT glb_nrdevias,
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT 0,
    INPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps024 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps024.pr_cdcritic WHEN pc_crps024.pr_cdcritic <> ?
       glb_dscritic = pc_crps024.pr_dscritic WHEN pc_crps024.pr_dscritic <> ?
       glb_stprogra = IF pc_crps024.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps024.pr_infimsol = 1 THEN TRUE ELSE FALSE. 
       
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

