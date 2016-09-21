/* ..........................................................................

   Programa: Fontes/crps656.p
   Sistema : CRIA/ATUALIZA PREJUIZO CYBER
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Agosto/2013.                     Ultima atualizacao: 14/11/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 76. Ordem = 3.
               Criar/Atualizar dados prejuizo na tabela crapcyb.

   Alteracoes: 02/10/2013 - Ajuste no campo qtmesdec para n�o gravar com valor
                            negativo.(James)             
                         
               28/10/2013 - Ajuste para atualizar o valor do prejuizo 
                            quando o contrato estiver liquidado (James)
                 
               14/11/2013 - Ajuste para nao atualizar as flag de judicial e
                            vip no cyber (James).
                            
               28/02/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
                  
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps656"
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

RUN STORED-PROCEDURE pc_crps656 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,
    INT(STRING(glb_flgresta,"1/0")),
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

CLOSE STORED-PROCEDURE pc_crps656 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps656.pr_cdcritic WHEN pc_crps656.pr_cdcritic <> ?
       glb_dscritic = pc_crps656.pr_dscritic WHEN pc_crps656.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps656.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps656.pr_infimsol = 1 THEN
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


