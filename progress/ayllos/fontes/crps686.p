 
 /* ............................................................................

    Programa: Fontes/crps686.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Jean Michel
    Data    : SETEMBRO/2014                     Ultima atualizacao: 23/09/2014

    Dados referentes ao programa:

    Frequencia: Diario
    Objetivo  : Quando a aplica��o atingir sua data de vencimento, o sistema 
                deve creditar o valor de resgate automaticamente na
                conta-corrente do cooperado.


    Alteracoes: 
 ............................................................................. */

 { includes/var_batch.i } 
 { sistema/generico/includes/var_oracle.i }

 ASSIGN glb_cdprogra = "crps686"
        glb_cdcritic = 0
        glb_dscritic = "".
       
 RUN fontes/iniprg.p.
                                                                        
 IF glb_cdcritic > 0 THEN DO:
   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - " + glb_cdprogra + "' --> '"  +
                     "Erro ao rodar: " + STRING(glb_cdcritic) + " " + 
                     "'" + glb_dscritic + "'" + " >> log/proc_batch.log").
   RETURN.
 END.

 ETIME(TRUE).
 
 { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

 RUN STORED-PROCEDURE PC_CRPS686 aux_handproc = PROC-HANDLE (INPUT glb_cdcooper,                                                  
                                                             INPUT INT(STRING(glb_flgresta,"1/0")),                                                            
                                                             OUTPUT 0,
                                                             OUTPUT 0,
                                                             OUTPUT 0, 
                                                             OUTPUT "").

 IF ERROR-STATUS:ERROR  THEN DO:
   DO aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
     ASSIGN aux_msgerora = aux_msgerora + 
                           ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
   END.

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                     " - " + glb_cdprogra + "' --> '"  +
                     "Erro ao executar Stored Procedure: '" +
                     aux_msgerora + "' >> log/proc_batch.log").
   RETURN.
 END.

 CLOSE STORED-PROCEDURE PC_CRPS686 WHERE PROC-HANDLE = aux_handproc.

 { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

 ASSIGN glb_cdcritic = 0
        glb_dscritic = ""
        glb_cdcritic = PC_CRPS686.pr_cdcritic WHEN PC_CRPS686.pr_cdcritic <> ?
        glb_dscritic = PC_CRPS686.pr_dscritic WHEN PC_CRPS686.pr_dscritic <> ?
        glb_stprogra = IF PC_CRPS686.pr_stprogra = 1 THEN TRUE ELSE FALSE
        glb_infimsol = IF PC_CRPS686.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


 IF glb_cdcritic <> 0 OR
    glb_dscritic <> "" THEN
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
