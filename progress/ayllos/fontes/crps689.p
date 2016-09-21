/*..............................................................................

   Programa: fontes/crps689.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2014                       Ultima atualizacao: 27/10/2014

   Dados referentes ao programa:
   Frequencia: A cada 5 min (Batch)
   
   Objetivo  : Processar arquivos refente a Pagamento de Titulos em Lote
              (Int.Bank.)

   Alteracoes: 27/10/2014 - Fixado o glb_cdcooper = 3 pois este crps sera
                            executado apenas na central
                            (Adriano).
..............................................................................*/


{includes/var_batch.i "NEW"}
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps689"
       glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcooper = 3.

ETIME(TRUE).

{ includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }

RUN STORED-PROCEDURE pc_crps689 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INT(STRING(glb_flgresta,"1/0")),
    OUTPUT 0,
    OUTPUT 0,
    OUTPUT 0, 
    OUTPUT "").

IF ERROR-STATUS:ERROR  THEN 
   DO:
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

CLOSE STORED-PROCEDURE pc_crps689 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps689.pr_cdcritic WHEN pc_crps689.pr_cdcritic <> ?
       glb_dscritic = pc_crps689.pr_dscritic WHEN pc_crps689.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps689.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps689.pr_infimsol = 1 THEN
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

        QUIT.
    END.                          

UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS")    + 
                  " - "   + glb_cdprogra + "' --> '"   +
                  "Stored Procedure rodou em "         + 
                  STRING(INT(ETIME / 1000),"HH:MM:SS") + 
                  " >> log/proc_batch.log").

/* .......................................................................... */


