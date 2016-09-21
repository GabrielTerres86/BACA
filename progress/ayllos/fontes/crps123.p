/* ..........................................................................

   Programa: Fontes/crps123.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/95.                       Ultima atualizacao: 01/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 040.
               Efetuar os lancamentos automaticos no sistema.
               Emite relatorio 101.

               Valores para insitlau: 1  ==> a processar
                                      2  ==> processada
                                      3  ==> com erro

   Alteracoes: 31/08/95 - Alterado para fazer a consistencia se o associado foi
                          transferido de conta (Odair).

               03/10/95 - Acerto na atualizacao da data do ultimo debito
                          (Deborah).

               08/10/96 - Alterado layout do frame f_integracao (Edson).

               09/04/97 - Alterado para permitir o debito de Telesc de faturas
                          canceladas apos a integracao (Deborah).

               05/05/97 - Atualizar dtdebito  (Odair).

               09/05/97 - Permitir lancamento de debitos de faturas Telesc
                          com autorizacao canceladas (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               15/07/98 - Colocar cdbccxpg 11 para lote (Odair)

               19/08/98 - Criar ndb para nao debitados de debitos automaticos 
                          atraves do includes/gerandb.i (Odair)

               28/08/98 - Mostrar no relatorio se esta em CL (Deborah). 

               09/11/98 - Tratar situacao em prejuizo (Deborah).

               11/01/99 - Acerto no layout do relatorio (Deborah).
               
               29/01/99 - Alimentar cdpesqbb com craplau.nrdcomto para tratar
                          debitos automaticos (CELESC,CASAN, etc).

               04/10/1999 - Alteracoes no relatorio (Deborah).

               30/10/1999 - Tratar cdrefere para telesc celular e 
                            fixa como nrcrcard (Odair)

               23/10/2000 - Desmembrar a critica 95 conforme a situacao do
                            titular (Eduardo).

               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               29/03/2001 - Criar um lote para cada quebra de PAC ou Banco de
                            pagamento (Edson).
                            
               24/07/2001 - Acrescentar criticas 722 e 723 no relatorio
                            (Junior).

               03/08/2001 - Alterado atualizacao do cdpesqbb (Margarete).

               21/08/2001 - Tratar onze posicoes no numero do documento (Edson).

               12/04/2002 - Atualizar os valores informados na capa do lote no
                            mesmo momento em que sao atualizados os valores 
                            computados (Junior).

               19/09/2003 - Quando histor 40 e cdbccxlt = 911 criar
                            craplcm.cdbccxlt = 100 (Margarete).
                            
               03/06/2004 - Incluido Critica 801 Prejuizo (Evandro) 
               
               09/06/2004 - Acessar banco Generico(Mirtes).

               22/12/2004 - Atualizar deta do ultimo debito no crapatr mesmo
                            se o historico estiver bloqueado (Julio)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craprej e craplcm (Diego).

               07/11/2005 - Tratamento para lancamento em duplicidade UNIMED
                            Hist. 509 (Julio)
               
               10/12/2005 - Atualizar craprej.nrdctabb (Magui).
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                           (Sidnei - Precise)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)
               
               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               18/05/2010 - Incluido tratamento para historico 834 - TIM 
                            conforme historico 288 (Elton)
               
               21/02/2011 - Incluir cdpesqbb na criacao do craprej (Magui).
               
               02/06/2011 - Desprezar craplau do TAA (Evandro).
               
               05/07/2011 - Tratamento para Liberty - 993 (Elton).
               
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               03/10/2012 - Tratamento para migracao Alto Vale de historicos de 
                            debito automatico (Elton).             
                            
               30/11/2012 - Ajuste migracao Alto Vale (Elton).             
               
               19/07/2013 - Tratamento para o Bloqueio Judicial (Ze).
               
               01/08/2013 - Tratamento com historicos de consorcio, cdhistor
                            1230, 1231, 1232, 1233, 1234 (Lucas R.).
                            
               04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               06/11/2013 - Ajustes migracao Acredi (Elton).             
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */

DEF BUFFER crabrej FOR craprej.

{ includes/var_batch.i  {1} } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps123"
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

RUN STORED-PROCEDURE pc_crps123 aux_handproc = PROC-HANDLE
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

CLOSE STORED-PROCEDURE pc_crps123 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps123.pr_cdcritic WHEN pc_crps123.pr_cdcritic <> ?
       glb_dscritic = pc_crps123.pr_dscritic WHEN pc_crps123.pr_dscritic <> ?
       glb_stprogra = IF pc_crps123.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps123.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


