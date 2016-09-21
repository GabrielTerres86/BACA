/* ..........................................................................

   Programa: Fontes/crps145.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                       Ultima atualizacao: 15/01/2014

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Efetuar os debitos dos valores aplicados referentes a Poupanca
               Programada.
               Emite relatorio 120. 

   Alteracoes: 21/10/96 - Alterado para verificar se ja foi feito aviso para
                          nao emitir outro. (Odair).

               14/01/97 - Alterado para tratar CPMF (Odair).

               04/02/97 - Arrumar calculo de saldo (Odair).

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               29/09/97 - Tratar flgproce (Odair).

               16/02/98 - Alterar a data final do CPMF (Odair)

               18/02/98 - Alterado para guardar o valor abonado (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar historico 289 (Edson).

               25/01/99 - Alterado para tratar abono IOF (Deborah).

               02/06/1999 - Tratar CPMF (Deborah).

               08/02/2001 - Aplicacoes RDCA60 e Poup. Progr. apos o dia 28 do
                            mes. (Eduardo).

               27/05/2002 - Nao gerar mais o pedido de impressao (Deborah). 

               26/03/2003 - Incluir tratamento da Concredi (Margarete).

               20/02/2004 - Nao emitir mais avisos de debito (Deborah).
               
               13/04/2004 - Tratar tab_indabono (Margarete).

               15/09/2004 - Tratamento  Conta Investimento(Mirtes).

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, craplpp, craprej, craplci e do buffer
                            crablot (Diego).
                 
               09/09/2005 - Efetuado acerto indicador debito(indebito)(Mirtes)
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               09/08/2007 - Cancelar as PPR a partir de 2008 (Guilherme).
                
               19/11/2007 - Comentada alteracao 2008 a pedido do Ivo (Magui). 

               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               11/01/2011 - Definido o format "x(40)" nmprimtl (Kbase - Gilnei).
                                                               
               28/07/2011 - Data do debito dever ser sempre a do mes
                            seguinte (Magui).
                        
               21/12/2011 - Aumentado o format do campo cdhistor 
                            de "999" para "9999" (Tiago).
                            
               11/01/2012 - Ajuste na alteracao de 28/07/2011, quando data de
                            debito for em dezembro e rodar em janeiro (David).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               15/01/2014 - Inclusao de VALIDATE craplot, craplcm, craplpp,
                            craprej, crablot e craplci (Carlos)
                            
               31/01/2014 - Migracao PROGRESS/ORACLE - Incluido chamada de
                            procedure (Andre Santos - SUPERO)
             
............................................................................. */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps145"
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

RUN STORED-PROCEDURE pc_crps145 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps145 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps145.pr_cdcritic WHEN pc_crps145.pr_cdcritic <> ?
       glb_dscritic = pc_crps145.pr_dscritic WHEN pc_crps145.pr_dscritic <> ?
       glb_stprogra = IF pc_crps145.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps145.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
