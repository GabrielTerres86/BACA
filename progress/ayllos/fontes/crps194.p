/* ..........................................................................

   Programa: Fontes/crps194.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/97                           Ultima atualizacao: 30/08/2011

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 013.
               Fazer limpeza de propostas nao aprovadas.
               Rodara no processo de limpeza mensal.
               
   Alteracoes: 13/08/98 - Incluida a limpeza dos cartoes solicitados (insitcrd
                          = 2) e nao recebidos (Deborah).
                          
               14/10/98 - Alterar a data limite da limpeza das propostas de
                          planos de capital (Deborah).
                          
               10/01/2000 - Padronizar mensagens (Deborah).

               07/02/2000 - Acerto no numero da mensagem (Deborah).

               07/02/2002 - Aumento do numero de dias para a limpeza das 
                            propostas de emprestimos (+ 30 dias) (Edson).

               11/04/2003 - Aumento do numero de dias para a limpeza das 
                            propostas de emprestimos (+ 60 dias) (Edson).
            
               30/06/2004 - Prever Avalistar Terceiros(Mirtes).
               
               26/08/2005 - Excluida a limpeza dos cartoes em situacao         
                            (insitcrd = 2) (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               06/03/2006 - Excluir a crapavt para os emprestimos (Evandro).
               
               27/04/2010 - As poupanças nao passam mais pelo estado de 
                            estudo, portanto nao sao mais criados os
                            registros (Gabriel).
                            
               22/07/2010 - Excluir dados da proposta , os bens dos contratos 
                            e os rendimentos (Gabriel).
                            
               30/08/2011 - Caso crawepr.tpemprst = 1 (pre-fixada)
                            entao, executar limpeza na crappep 
                            (parcelas do emprestimo). (Fabricio)
               
............................................................................. */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps194"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps194 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps194 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps194.pr_cdcritic WHEN pc_crps194.pr_cdcritic <> ?
       glb_dscritic = pc_crps194.pr_dscritic WHEN pc_crps194.pr_dscritic <> ?
       glb_stprogra = IF pc_crps194.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps194.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


