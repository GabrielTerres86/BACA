/*..........................................................................

   Programa: Fontes/crps297.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Outubro/2000.                       Ultima atualizacao: 15/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 001.
               Fazer a cobertura do saldo devedor das contas de cheque
               administrativo e de outras contas especiais.

   Alteracoes: 26/05/2004 - Adicionar mais 2 vias para viacredi (Ze Eduardo).
   
               30/06/2005 - Alimentado campo cdcooper das tabelas craplot
                            e craplcm (Diego).
                            
               16/08/2005 - Utilizar o historico 612 quando a cooperativa for
                            VIACREDI e a conta for 83.000-3 (Edson).

               12/09/2005 - Utilizar o historico 612 quando a cooperativa for
                            VIACREDI e a conta for 85.000-4 (Edson).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
                
               31/03/2006 - Concertada clausula OR do FOR EACH, pondo entre
                            parenteses (Diego).

               31/08/2007 - Alterado para 1 via Viacredi(Mirtes)
               
               09/06/2008 - Incluído o mecanismo de pesquisa no "find" na 
                            tabela CRAPHIS para buscar primeiro pela chave de
                            acesso (craphis.cdcooper = glb_cdcooper). 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.

               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps297"
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

RUN STORED-PROCEDURE pc_crps297 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps297 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps297.pr_cdcritic WHEN pc_crps297.pr_cdcritic <> ?
       glb_dscritic = pc_crps297.pr_dscritic WHEN pc_crps297.pr_dscritic <> ?
       glb_stprogra = IF pc_crps297.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps297.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


