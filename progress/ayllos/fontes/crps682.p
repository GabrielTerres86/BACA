/* ........................................................................... 
   
   Programa: Fontes/crps682.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Jaison
   Data    : Maio/2014.                    Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Semanal (Segunda-feira)
   Objetivo  : Seleção de cooperados que terao Credito Pre Aprovado.
   
   Alteracoes: 26/11/2014 - Verificacao se o processo noturno esta rodando 
                            e tbm se eh segunda-feira. (Jaison)
							
			   29/01/2018 - Projeto Ligeirinho - Foram incluidos novos parâmetros 
						    na chamada da rotina para execução do programa utilizando 
							paralelismo. (Roberto - Amcom)
						
   
 ........................................................................... */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps682"
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

/* Processo noturno rodando e tbm eh segunda-feira */
IF  glb_inproces <> 1 AND WEEKDAY(glb_dtmvtolt) = 2 THEN
    DO:
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        
        RUN STORED-PROCEDURE pc_crps682 aux_handproc = PROC-HANDLE
           (INPUT glb_cdcooper, 
		    INPUT 0,
			INPUT 0,
			INPUT 0,
            INPUT INT(STRING(glb_flgresta,"1/0")),
            INPUT  0, /* NAO Gerar arquivo TXT para SPC/Serasa */
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
        
        CLOSE STORED-PROCEDURE pc_crps682 WHERE PROC-HANDLE = aux_handproc.
        
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN glb_cdcritic = 0
               glb_dscritic = ""
               glb_cdcritic = pc_crps682.pr_cdcritic WHEN pc_crps682.pr_cdcritic <> ?
               glb_dscritic = pc_crps682.pr_dscritic WHEN pc_crps682.pr_dscritic <> ?
               glb_stprogra = IF pc_crps682.pr_stprogra = 1 THEN TRUE ELSE FALSE
               glb_infimsol = IF pc_crps682.pr_infimsol = 1 THEN TRUE ELSE FALSE.

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
