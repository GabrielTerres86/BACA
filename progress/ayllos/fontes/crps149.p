/* ..........................................................................

   Programa: Fontes/crps149.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/96.                       Ultima atualizacao: 30/03/2015

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 001.
               Gerar lancamento de cobranca de taxa de contrato de emprestimo.

   Alteracoes: 26/08/96 - Alterado para nao gerar aviso para os associados que
                          tenham tipo de conta igual a 5 ou 6 (Edson).

               05/11/96 - Alterado para creditar o valor do novo emprestimo e
                          debitar as liquidacoes de contratos antigos na conta-
                          corrente (Edson).

               19/11/96 - Alterado para descontar o valor provisionado no
                          cheque salario na liquidacao do emprestimo (Edson).

               28/05/97 - Alterado para verificar se deve ou nao cobrar
                          tarifa e se deve creditar o valor liquido em uma
                          conta especial (Edson).

               26/06/97 - Nao emitir aviso de debito da taxa de empr. (Odair)

               27/08/97 - Alterado para incluir o campo flgproce na criacao
                          do crapavs (Deborah).

               16/03/98 - Mudanca do historico 108 para 282 (Deborah).

               27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               11/08/98 - Alterado para incluir a secao para extrato no 
                          craprej (Edson).
                          
               10/09/98 - Tratar tipo de conta 7 (Deborah).

               19/01/1999 - Cobranca do IOF (Deborah).

               02/06/1999 - Tratar CPMF (Deborah).
                            O programa nao fara mais a transferencia para a
                            conta administrativa e nem o debito na conta
                            original, portanto, nao se faz necessario cal-
                            cular o CPMF para encontrar o valor do liquido do
                            emprestimo. Ainda assim, foi alterado para ficar 
                            compativel com a nova edicao no CPMF. 

               01/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner). 
               
               06/08/2001 - Tratar prejuizo de conta corrente (Margarete).

               20/12/2002 - Tratar linhas de credito com tarifa especial.
                            Implementado valor de isencao na tabela (Deborah).
                            
               08/01/2003 - Alterar pesquisa de taxas de emprestimo, devido a
                            inclusao de nova faixa (Junior).

               23/03/2003 - Incluir tratamento da Concredi (Margarete).

               11/06/2004 - Se credito for bloqueado, parte referente a 
                            liquidacao (SALDO + CPMF) devera ser  feita com
                            novo historido(Liberado)(Mirtes)
     
               28/06/2004 - Prever Liquidacao com valor Emprestimo Parcial
                            (Mirtes)

               29/06/2005 - Alimentado campo cdcooper das tabelas craplot,
                            craplcm, craprej, craplem e crapdpb (Diego).
                            
               10/12/2005 - Atualizar craprej.nrdctitg (Magui).             
               
               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               
               23/02/2006 - Tratar linha de credito que NAO tem credito em
                            conta-corrente do Associado (Edson).
               08/03/2006 - Incluida cooperativa 1 (linha de credito que nao
                            tem credito em conta corrente(Mirtes).
                            
               17/03/2006 - Atualizada atribuicao da flag aux_flgcrcta
                            (Diego).
                
               17/04/2006 - Inclusao de mais duas faixas para cobranca de 
                            tarifa de emprestimo. (Julio).

               29/05/2006 - Desabilitado o trecho de codigo que faz referencia
                            a tabela crapfol (Julio)
                            
               24/01/2007 - Se "aux_flgcrcta = false", entao nao gerar craprej
                            para contratos de emprestimos liquidados (Julio)
                            
               20/04/2007 - Baixar avisos pendentes, quando houver liquidacao
                            de emprestimos vinculados a folha (Julio).
                            
               03/01/2008 - Cobranca de IOF a partir de 03/01/2008 (Magui).
               
               12/02/2008 - Nao cobrar IOF na linha 900 - Desc.Chq.Vencido 
                            (Guilherme).
                            
               19/02/2008 - Nao cobrar IOF na linha 100 - Desc.Chq.Vencido 
                            (Guilherme).             
               
               02/04/2008 - Colocar no craplcm.nrdocmto a soma do numero do
                            documento e sequencial de lote para os historicos
                            161, 18 e 622 para nao causar duplicacao de
                            registros (Evandro).
                            
               30/09/2008 - Cada historico com seu lote (Magui).
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               27/08/2009 - Incluido tratamento na critica 484, de modo que 
                            nao pare o processo (Diego).

               26/03/2010 - Desativar RATING quando for liquidado
                            o emprestimo (Gabriel).
                            
               13/05/2010 - Nao cobrar IOF na linha de credito 800 (Elton).
               
               15/09/2010 - Alterado historico 161 para 891. Demanda Auditoria 
                            BACEN (Guilherme).
                            
               16/03/2011 - Realizado correcao no calculo do IOF (Adriano).
               
               06/03/2012 - Ajustando para o novo empréstimo (Oscar). 
               
               19/03/2012 - Declarado as variaveis necessarias para uso da 
                            include lelem.i (Tiago).
                            
               02/04/2012 - Usar o novo campo dtlibera (Oscar).             
               
               23/05/2012 - Tarifar IOF de acordo com parametro da LCREDI.
                            (Irlan).
                            
               14/06/2012 - Ajustar tarifa de contrato (Gabriel) 
               
               09/07/2013 - Alteracao cobranca tarifa emprestimo/financiamento
                            e inclusao rotina para cobranca tarifa avaliacao de
                            bens em garantia, projeto Tarifas (Daniel)
                            
               03/09/2013 - Tratamento para Imunidade Tributaria (Ze).               
               
               05/09/2013 - Chamada da procedure 
                            carrega_dados_tarifa_emprestimo ao inves da
                            carrega_dados_tarifa_vigente levando em 
                            cosideracao as particularidades da chamada de
                            cada uma delas, fazendo o devido ajuste (Tiago).
                            
               11/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               05/11/2013 - Incluido o parametro cdpactra na chamada da 
                            procedure efetua_liquidacao_empr (Adriano).
                            
               27/11/2013 - Retirado comentarios referente tarifacao Ok (Daniel).             
               
               16/01/2014 - Inclusao de VALIDATE craplot, craplcm, craprej, 
                            craplem, crapdpb (Carlos)
                            
               19/02/2014 - Ajustado o lancamento do historico 282, para nao 
                            cobrar juros de mora e multa.  (James)
                            
               24/02/2014 - Ajuste no calculo da variavel aux_vlsderel (James)
               
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                           posicoes (Tiago/Gielow SD137074).

               16/06/2014 - Implementacao da rotina de envio de e-mail 
                            para tarifas@cecred.coop.br de LOG's do tipo: 
                            "Erro Faixa Valor Coop.! Tar: 129 Fvl: 131 Lcr: 562"
                            (Carlos Rafael SD159931).
                            
               23/07/2014 - Incluir parametro par_nrseqava na chamada da 
                            procedure efetua_liquidacao_empr. (James)
                            
               28/07/2014 - Ajuste para quando ocorrer erro, nao abortar o 
                            programa. (James)
                            
               11/09/2014 - Ajuste para nao ocorrer o credito em conta
                            quando a origem for TAA e InternetBank. (James)
                            
               07/10/2014 - Ajuste para gravar o valor da tarifa e IOF na
                            crapepr. (James)

               02/12/2014 - Inclusao da chamada do solicita_baixa_automatica
                            (Guilherme/SUPERO)
               
               20/01/2015 - Alterado o formato do campo nrctremp para 8 
                            caracters (Kelvin - 233714)
                            
               30/03/2015 - Criacao do programa hibrido. Alisson (AMcom)
               
........................................................................... */

{ includes/var_batch.i } 
{ sistema/generico/includes/var_oracle.i }

ASSIGN glb_cdprogra = "crps149"
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

RUN STORED-PROCEDURE pc_crps149 aux_handproc = PROC-HANDLE NO-ERROR
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

CLOSE STORED-PROCEDURE pc_crps149 WHERE PROC-HANDLE = aux_handproc.

{ includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

ASSIGN glb_cdcritic = 0
       glb_dscritic = ""
       glb_cdcritic = pc_crps149.pr_cdcritic WHEN pc_crps149.pr_cdcritic <> ?
       glb_dscritic = pc_crps149.pr_dscritic WHEN pc_crps149.pr_dscritic <> ?
       glb_stprogra = IF pc_crps149.pr_stprogra = 1 THEN TRUE ELSE FALSE
       glb_infimsol = IF pc_crps149.pr_infimsol = 1 THEN TRUE ELSE FALSE. 


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
