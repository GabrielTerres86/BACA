/* ..........................................................................

   Programa: Fontes/crps335.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah    
   Data    : Dezembro/2002                   Ultima atualizacao: 07/06/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 001.
               Lancar tarifa de debito em conta corrente se a conta estiver 
               negativa e houver comp no dia.             

   Alteracoes: 12/04/2004 - Tabela Alterada de VLTARIFEST p/VLTARIFDIV(Mirtes)
   
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder          
                  
               30/06/2008 - Incluida chave de acesso
                            (craphis.cdcooper = glb_cdcooper ) no "find".
                            - Kbase IT Solutions - Paulo Ricardo Maciel.
                              
               30/10/2008 - Alterado lote 8452 para 10029 (Magui).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               08/01/2010 - Acrescentar historicos 469 e 572 na variavel
                            aux_lshistor (Guilherme/Precise)

               02/03/2010 - Alterar historicos 469 para 524 (Guilherme/Precise)
               
               07/06/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
               
............................................................................. */

{ includes/var_batch.i }
{ sistema/generico/includes/var_oracle.i }


ASSIGN glb_cdprogra = "crps335"
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

RUN STORED-PROCEDURE pc_crps335 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT glb_cdoperad,
    INPUT glb_inproces,
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
        
CLOSE STORED-PROCEDURE pc_crps335 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps335.pr_cdcritic WHEN pc_crps335.pr_cdcritic <> ?
       glb_dscritic = pc_crps335.pr_dscritic WHEN pc_crps335.pr_dscritic <> ?.
       glb_stprogra = IF pc_crps335.pr_stprogra = 1 THEN
                         TRUE
                      ELSE
                         FALSE.
       glb_infimsol = IF pc_crps335.pr_infimsol = 1 THEN
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

