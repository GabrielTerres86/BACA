/* .............................................................................

   Programa: fontes/crps289.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/2000                         Ultima atualizacao: 25/04/2011

   Dados referentes ao programa:

   Frequencia: Por solicitacao
   Objetivo  : Listar etiquetas para com dados dos associados para selar cartas
               pela solicitacao 77.

   Alteracoes: 22/12/2000 - Imprimir etiquetas nas impressoras a laser 
                            (Eduardo).

               31/07/2002 - Incluir nova situacao da conta (Margarete).
               
               05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo)
               
               06/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               19/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).

               27/07/2006 - Efetuado acerto no format do campo rel_linhaimp[2]
                            (Diego).

               21/11/2006 - Modificado layout das etiquetas (Diego).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               25/04/2011 - Aumentar formatos da cidade e bairro (Gabriel).                         
........................................................................... */

{ includes/var_batch.i "new" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps289"
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

RUN STORED-PROCEDURE pc_crps289 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps289 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps289.pr_cdcritic WHEN pc_crps289.pr_cdcritic <> ?
       glb_dscritic = pc_crps289.pr_dscritic WHEN pc_crps289.pr_dscritic <> ?
       glb_stprogra = IF pc_crps289.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps289.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


