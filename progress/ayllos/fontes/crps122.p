/* ..........................................................................

   Programa: Fontes/crps122.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Junho/95.                        Ultima atualizacao: 16/02/2006

   Dados referentes ao programa:
   Frequencia: Roda Mensalmente no Processo de Limpeza
   Objetivo  : Limpeza dos Avisos de Debito em C/C (crapavs).

               Atende a Solicitacao 013.
               Ordem da Solicitacao 065.
               Exclusividade = 2
               Ordem do Programa na Solicitacao = 16

   Alteracoes: 30/06/95 - Alterado para eliminar da leitura a selecao de tipo
                          de aviso 1 (limpara todos os tipo de avisos).
                          Nao atualizar tabela de execucao e a solicitacao.
                          (Deborah)

               10/01/2000 - Padronizar mensagens (Deborah). 
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               31/03/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)

............................................................................. */

{ includes/var_batch.i "NEW" } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps122"
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

RUN STORED-PROCEDURE pc_crps122 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps122 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps122.pr_cdcritic WHEN pc_crps122.pr_cdcritic <> ?
       glb_dscritic = pc_crps122.pr_dscritic WHEN pc_crps122.pr_dscritic <> ?
       glb_stprogra = IF pc_crps122.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps122.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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