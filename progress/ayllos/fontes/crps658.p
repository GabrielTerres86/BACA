/* ..........................................................................

Programa: Fontes/crps658.p
Sistema : Conta-Corrente - Cooperativa de Credito
Sigla   : CRED
Autora  : Lucas R.
Data    : Setembro/2013                        Ultima atualizacao: 29/11/2013

Dados referentes ao programa:

Frequencia: Diario (Batch).
Objetivo  : Importar os arquivos de atualizacao das informacoes dos
            consorcios do Sicredi e gerara relatorio crrl667.

Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                         a glb_cdcritic <> 0 antes do return. (Lucas R.)
                         
            29/11/2013 - Ajustes no for each crapcns, retirado o INT das
                         variaveis. Ajustado para que quando data errada na 
                         linha detalhe gera critica no relatorio 667 (Lucas R.)
............................................................................*/

DEF STREAM str_1.   /*  Para relatorio de criticas crrl667 */
DEF STREAM str_2.   /*  Para arquivo de importacao         */
DEF STREAM str_3.   /*  Para arquivo                       */

{ includes/var_batch.i }  
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps658"
       glb_cdrelato = 667
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

RUN STORED-PROCEDURE pc_crps658 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps658 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps658.pr_cdcritic WHEN pc_crps658.pr_cdcritic <> ?
       glb_dscritic = pc_crps658.pr_dscritic WHEN pc_crps658.pr_dscritic <> ?
       glb_stprogra = IF pc_crps658.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps658.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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



