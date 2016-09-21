/* ..........................................................................

   Programa: Fontes/crps442.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2007                     Ultima atualizacao: 12/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 82.
               Efetuar os lancamentos dos creditos do INSS - BANCOOB

   Alteracoes: 04/03/2008 - Ajuste para creditar com glb_dtmvtopr (Evandro).
   
               05/03/2008 - Alterado o lote de 10111 para 10114 (Evandro).
               
               06/03/2008 - Colocar o credito como enviado pois o BANCOOB baixa
                            automaticamente os creditos em C/C (Evandro).
                            
               02/02/2012 - O processo de geracao do lote e do lancamento
                            foi passado para a procedure gera_credito_em_conta
                            criado na b1wgen0091 (Adriano).             
                            
               07/12/2012 - Incluido procedure transfere_beneficio para
                            transferencia dos beneficios para altovale
                            (Tiago).            

               12/09/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                            
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps442"
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

RUN STORED-PROCEDURE pc_crps442 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INPUT INT(STRING(glb_flgresta,"1/0")),                                         OUTPUT 0,
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

CLOSE STORED-PROCEDURE pc_crps442 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps442.pr_cdcritic WHEN pc_crps442.pr_cdcritic <> ?
       glb_dscritic = pc_crps442.pr_dscritic WHEN pc_crps442.pr_dscritic <> ?
       glb_stprogra = IF  pc_crps442.pr_stprogra = 1 THEN 
                          TRUE
                      ELSE
                          FALSE
       glb_infimsol = IF  pc_crps442.pr_infimsol = 1 THEN 
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

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").
                  
RUN fontes/fimprg.p.

/* .......................................................................... */
