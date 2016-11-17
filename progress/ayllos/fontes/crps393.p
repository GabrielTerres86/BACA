/*.............................................................................

  Programa: Fontes/crps393.p
  Sistema: Conta-Corrente Cooperativa de Credito
  Sigla: CECRED
  Autor: Evandro
  Data: Junho/2004                       Ultima Atualizacao: 12/11/2013

  Dados referentes ao programa:
  
  Frequencia: Mensal.
  Objetivo  : Atende a solicitacao 101.
              Emite um relatorio (listagem) de CPF nao consultados (352).
              
  Alteracoes: 10/10/2005 - Alterado para gerar arquivos separadamente por PAC,
                           acrescentados campos TTL. e SITUACAO (Diego).

              17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                            
              14/07/2006 - Inclusao do campo Data de Consulta CPF (Elton).

              17/08/2006 - Nao estava jogando todos para a impressora(Magui).
              
              23/05/2007 - Incluido infimsol = true(Guilherme)
              
              09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
              12/11/2013 - Alterado totalizador de PAs de 99 para 999.
                           (Reinert)                            
.............................................................................*/

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps393"
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

RUN STORED-PROCEDURE pc_crps393 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps393 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps393.pr_cdcritic WHEN pc_crps393.pr_cdcritic <> ?
       glb_dscritic = pc_crps393.pr_dscritic WHEN pc_crps393.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps393.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps393.pr_infimsol = 1 THEN
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
                  
RUN fontes/fimprg.p.

       
/* .......................................................................... */


