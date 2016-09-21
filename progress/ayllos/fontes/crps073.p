/* .............................................................................

   Programa: Fontes/crps073.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Novembro/93.                        Ultima atualizacao: 15/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (Batch - Background).
   Objetivo  : Atende a solicitacao 039
               Emitir resumo dos historicos por agencia (62) e resumo geral
               da compensacao das contas convenio (79).

   Alteracoes: 09/06/94 - Alterado para emitir um resumo por conta convenio do
                          Banco do Brasil com a quantidade e valor compensado
                          no mes de referencia (Edson).

               28/09/94 - Na selecao dos lancamentos foi substuido o cdpesqbb
                          pelo nrdolote (Edson).

               04/11/94 - Alterado para incluir  a  leitura  do  craplct  e  do
                          craplem acumulando na tabela e listando de historicos
                          e listar os totais de lancamento (Odair).

               07/12/95 - Dar o mesmo tratento do tipo de conta 5 para o tipo de
                          conta 6 (Odair).

               12/11/97 - Na leitura de lotes de compensacao (faixa 7000), sele-
                          cionar apenas hist. 50,56,59 e retirar faixa dos
                          7000 do lote (Odair)

               24/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               11/09/98 - Tratar tipo de conta 7 (Deborah).

               07/07/99 - Listar total de contas BANCOOB (Odair)
               
               31/08/99 - Mostrar cheques devolvidos por Convenio (Odair)

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               21/07/2000 - Tratar historico 358 (Deborah).

               05/07/2001 - Duas vias no relatorio (Deborah).

               05/03/2002 - Incluir indice de devolucao do Banco do Brasil,
                            Bancoob e total no relatorio 79 (Junior). 

               23/05/2002 - incluir indice de devolucao por PAC (Deborah).

               27/03/2003 - Adicionar alinea 156 (Junior).

               11/04/2003 - Adicionar Caixa Economica - Concredi (Ze Eduardo).

               22/11/2004 - Incluido TOTAIS ao final do Resumo das devolucoes
                            por PAC (Evandro).

               24/11/2004 - Tirada a flag de fim de solicitacao glb_infimsol
                            (Evandro).

               17/02/2005 - Incluidos tipos de conta Integracao(12/13/14/15)
                                                           (Mirtes).

               15/03/2005 - Na listagem por PAC, alterado para exibir se houver
                            qualquer valor (Evandro).

               07/06/2005 - Incluidos tipos de conta Integracao(17/18)(Mirtes)

               10/08/2005 - Efetuado acerto calculo(campo tot_perceger)(Mirtes)

               14/09/2005 - Efetuado acerto calculo(campo tot_percbbra)(Diego).

               23/12/2005 - Tratamento para Conta Integracao (Ze).

               24/01/2006 - Listar conta integracao (Edson).

               15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               21/02/2006 - Alterado para imprimir 1 via(crrl079) (Diego).

               24/09/2007 - Acertado calculo dos campos tot_percbcob e
                            tot_perccaix referente a porcentagem de devolucao
                            dos cheques do bancoob e da caixa (Elton). 

               14/11/2007 - Substituidas algumas variaveis EXTENT por campos
                            em TEMP-TABLE (Diego).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

               15/12/2008 - Substituir a tab "ContaConve" pela gnctace (Ze).
                          - Aumentado formato dos totais dos historicos
                            (Gabriel).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               30/07/2010 - Alteracao do relat Dev. Efetuada por Alinea de CEF
                            para Cecred e inclusao do Resumo Mensal Compensacao
                            para Cecred. (Guilherme/Supero)
                            
               13/09/2010 - Acerto no Relatorio (Ze).
               
               15/09/2010 - Incluir o cdcooper no for each do ass 
                            para melhorar o desempenho (Gabriel).
                            
               30/05/2011 - Incluir o historico 573 (Ze).             

               08/06/2011 - Acerto nas devolucoes por alinea (Magui).
               
               12/09/2012 - Incluir o historico 521 (Ze).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

DEF STREAM str_1.     /*  Para resumo dos historicos por agencia  */
DEF STREAM str_2.     /*  Para resumo geral da comp. das contas convenio  */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps073"
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

RUN STORED-PROCEDURE pc_crps073 aux_handproc = PROC-HANDLE
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
    QUIT.
END.

CLOSE STORED-PROCEDURE pc_crps073 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps073.pr_cdcritic WHEN pc_crps073.pr_cdcritic <> ?
       glb_dscritic = pc_crps073.pr_dscritic WHEN pc_crps073.pr_dscritic <> ?
       glb_stprogra = IF pc_crps073.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps073.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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


