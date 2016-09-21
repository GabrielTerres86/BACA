/* ..........................................................................

   Programa: Fontes/crps326.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Maio/2002.                        Ultima atualizacao: 16/01/2015

   Dados referentes ao programa:

   Frequencia: Mensal.
   Objetivo  : Atende a solicitacao 004.
               Listar mensalmente os contratos de limite de cheque especial
               vencidos.
               Emite relatorio 275 - 132 colunas.

   Alteracoes: 16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
   
               24/04/2007 - Subst. tabela "LIMCHEQESP" por craplrt e criar
                            tabela temporaria  (Ze).

               22/02/2008 - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).
                            
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               11/09/2009 - Adicionar novo campo craplim.vllimit - "Valor Lim."
                            e ajustar leitura do telefone do cooperado, passar
                            a utilizar a craptfc (Fernando).
                            
               25/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
               16/01/2014 - Ajuste para rodar somente na mensal. (James)
............................................................................. */

{ includes/var_batch.i}
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps326"
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

/* Somente ira rodar na mensal */
IF MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
   DO:
       { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

       RUN STORED-PROCEDURE pc_crps326 aux_handproc = PROC-HANDLE
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
               
       CLOSE STORED-PROCEDURE pc_crps326 WHERE PROC-HANDLE = aux_handproc.
       
       { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
       
       ASSIGN glb_cdcritic = 0
              glb_dscritic = ""
              glb_cdcritic = pc_crps326.pr_cdcritic WHEN pc_crps326.pr_cdcritic <> ?
              glb_dscritic = pc_crps326.pr_dscritic WHEN pc_crps326.pr_dscritic <> ?.
              glb_stprogra = IF pc_crps326.pr_stprogra = 1 THEN
                                TRUE
                             ELSE
                                FALSE.
              glb_infimsol = IF pc_crps326.pr_infimsol = 1 THEN
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
       
               RETURN.
           END.
   END.

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* .......................................................................... */
