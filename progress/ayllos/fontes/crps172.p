/* ..........................................................................
   Programa: Fontes/crps172.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/96                     Ultima atualizacao: 19/08/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente a prestacao do plano de capital.

   Alteracoes: 16/01/97 - Tratar CPMF (Odair).

               04/02/97 - Arrumar calculo de saldo tratar abono (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               02/12/97 - Alterado o numero do lote (Deborah).

               30/01/98 - Alterado para usar a rotina calcdata (Deborah).

               16/02/98 - Tratar final da CPMF (Odair)

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               02/06/1999 - Tratar CPMF (Deborah).  

               26/03/2003 - Incluir tratamento da Concredi (Margarete).
               
               11/04/2003 - Comparar com o total de prestacoes plano capital.
                            (Ze Eduardo).

               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplct, craplcm, crapavs e craprej (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               22/02/2008 - Alterado para mostrar turno a partir de 
                            crapttl.cdturnos (Gabriel). 

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               26/05/2009 - Quando primeiro dia util do mes pagando cotas
                            do mes anterior por feriado ou fim de semana
                            deixar indpagto como 0 para cobrar o debito
                            do mes (Magui).

               19/10/2009 - Alteracao Codigo Historico (Kbase).                            
               
               21/12/2011 - Aumentado o format do campo cdhistor
                            de "999" para "9999" (Tiago).
                            
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               19/08/2013 - Quando nao possuir saldo suficiente para o debito
                            de cotas, mantem o indpagto = 0 e atribui o valor
                            da prestacao de cotas ao campo vlpenden. (Fabricio)
............................................................................ */

{ includes/var_batch.i }   
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps172"
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

RUN STORED-PROCEDURE pc_crps172 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps172 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps172.pr_cdcritic WHEN pc_crps172.pr_cdcritic <> ?
       glb_dscritic = pc_crps172.pr_dscritic WHEN pc_crps172.pr_dscritic <> ?
       glb_stprogra = IF pc_crps172.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps172.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


