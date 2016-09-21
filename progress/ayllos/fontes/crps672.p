/* ............................................................................

   Programa: crps672 ----> PC_CRPS672
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas Lunelli
   Data    : Abril/2014.                        Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Di�rio.
   Objetivo  : Atende a solicitacao 01, Ordem 36.
               Tratar arquivo de retorno da Solicita��o de Cart�o (Bancoob/CABAL).
                                 Relat�rio crrl676 - Rejei��es Processamento Arq. Retorno

   Alteracoes: 

.............................................................................*/   

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps672"
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

RUN STORED-PROCEDURE PC_CRPS672 aux_handproc = PROC-HANDLE (INPUT glb_cdcooper,                                                  
                                                            INPUT INT(STRING(glb_flgresta,"1/0")),                                                            
                                                            OUTPUT 0,
                                                            OUTPUT 0,
                                                            INPUT glb_cdoperad,
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

CLOSE STORED-PROCEDURE PC_CRPS672 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = PC_CRPS672.pr_cdcritic WHEN PC_CRPS672.pr_cdcritic <> ?
       glb_dscritic = PC_CRPS672.pr_dscritic WHEN PC_CRPS672.pr_dscritic <> ?
       glb_stprogra = IF PC_CRPS672.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF PC_CRPS672.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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

