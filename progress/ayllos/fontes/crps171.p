/* ..........................................................................
   Programa: Fontes/crps171.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Outubro/96.                     Ultima atualizacao: 23/07/2013

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 001.
               Debitar em conta corrente a prestacao dos emprestimos.
               Emite relatorio 135.

   Alteracoes: 10/01/97 - Tratar CPMF (Odair).

               04/02/97 - Arrumar calculo de saldo devido a abono (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               30/01/98 - Alterado para usar a rotina calcdata (Deborah).

               16/02/98 - Alterar a data final do CPMF (Odair).

               28/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               29/06/98 - Alterado para NAO tratar o historico 289 (Edson).

               02/06/1999 - Tratar CPMF (Deborah).

               13/10/1999 - Imprimir fone quando ramal 9999. (Odair)

               24/11/1999 - Colocar fone com 10 casas (Odair)
               
               11/10/2000 - Alterar formato do telefone (Margarete/Planner)
               
               06/03/2001 - Separar o relatorio por pac. (Ze Eduardo).

               24/10/2001 - Tentar sempre debitar o atraso (Margarete).

               25/02/2002 - Nao enxerga pagtos no caixa (Margarete).

               04/03/2002 - Sempre descontar a prestacao do mes (Margarete).
               
               10/05/2002 - Qdo 91 nao cobra o valor correto (Margarete).
               
               28/05/2002 - Nao gerar mais o pedido de impressao (Deborah).
               
               26/08/2002 - Para saldo varre >= glb_dtmvtolt (Margarete).

               28/10/2002 - Tratar cobertura de saldos devedores (Deborah).

               06/11/2002 - Qdo paga todo atraso no mes nao vira a data
                            corretamente (Margarete).

               27/03/2003 - Incluir tratamento da Concredi (Margarete).

               03/06/2004 - Quando pago por fora ainda estava mostrando
                            no crrl135 (Margarete).

               21/06/2004 - Quando pago algo durante o mes nao mostrava o 
                            saldo que ainda faltava pagar(Margarete).
                            
               22/09/2004 - Incluidos historicos 498/500(CI)(Mirtes)
               
               24/09/2004 - Tratamento para emprestimo em consignacao (Julio).
               
               06/10/2004 - So vai lancar no craplcm se nao for emprestimo
                            consignado ou se o dia for maior que 10 (Julio)
                            
               15/06/2005 - So atualiza inliquid se realmente lancou na conta
                            (Julio)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, crapavs, craplem e craprej (Diego).

               15/07/2005 - Calculo do abono da cpmf deve enxergar a data
                            de inicio, tab_dtiniabo. Usa craplcm.dtrefere
                            com craprda.dtmvtolt para pegar se lancamento com
                            abono ou nao (Margarete).
                            
               08/09/2005 - Faltando um pouco para pagar nao mostrava no
                            relatorio (Margarete).

               10/12/2005 - Atualiza craplcm.nrdctitg (Magui).
               
               15/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               17/03/2006 - Quando vencimento depois do ultimo dia util do
                            mes nao cobrava correto (Magui).
               19/04/2006 - Se pagamento antes do aniversario nao estava
                            descontado, queria cobrar tudo novamente (Magui).
                            
               15/05/2006 - Aumento da mascara para o numero do contrato 
                            (Julio)

               23/06/2006 - Incluido campo para Observacoes (David).
               
               28/02/2007 - Carregar fones da tabela craptfc (David).
               
               21/02/2008 - Mostrar turno da crapttl.cdturnos (Gabriel).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               17/11/2008 - Nao esta debitando quando a prestacao e menor
                            que o valor minimo do debito (Magui).

               19/06/2009 - Nao permitir debito em conta corrente para 
                            emprestimos com pagamentos via boleto (Fernando).
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               23/10/2009 - Quando for criado um registro na craplem, inclui "9"
                            no numero de documento, caso o registro ja exista
                            (Elton).
               
               26/03/2010 - Desativar o Rating quando liquidado o emprestimo
                            (Gabriel).                                         
                                                                                               29/10/2010 - Alteracao para gerar relatorio em txt
                            (GATI-Sandro)
                            
               14/02/2011 - Inclusao para gerar txt para Acredicoop;
                          - Alteracao para mover arquivos para diretorio 
                            salvar (GATI - Eder).
                            
              21/12/2011 - Aumentado o format do campo cdhistor
                           de "999" para "9999" (Tiago).             
                           
              09/03/2012 - Declarado as variaveis necessarias para utilizacao
                           da include lelem.i (Tiago)             
                           
              07/11/2012 - Alterado para debitar somente emprestimos do tipo
                           zero (Oscar)
                       
              27/12/2012 - Gerar arquivo TXT para AltoVale (Evandro).
              
              23/07/2013 - Migracao PROGRESS/ORACLE - Incluido chamada de
                           procedure (Andre Santos - SUPERO)
              
............................................................................ */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps171"
       glb_flgbatch = FALSE
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

RUN STORED-PROCEDURE pc_crps171 aux_handproc = PROC-HANDLE
   (INPUT glb_cdcooper,                                                  
    INPUT INT(STRING(glb_flgresta,"1/0")),
    INPUT 0,
    INPUT 0,
    INPUT glb_cdoperad,
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

CLOSE STORED-PROCEDURE pc_crps171 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0                           
       glb_dscritic = ""
       glb_cdcritic = pc_crps171.pr_cdcritic WHEN pc_crps171.pr_cdcritic <> ?
       glb_dscritic = pc_crps171.pr_dscritic WHEN pc_crps171.pr_dscritic <> ?
       glb_stprogra = IF pc_crps171.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps171.pr_infimsol = 1 THEN TRUE ELSE FALSE. 

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

/*.......................................................................... */